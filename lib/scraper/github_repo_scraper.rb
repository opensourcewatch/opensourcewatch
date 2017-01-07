require_relative './noko_doc'

# Scrapes data for Repositories and Users on Github.com
class GithubRepoScraper
  @github_doc = NokoDoc.new
  @current_repo = nil
  @SECONDS_BETWEEN_REQUESTS = 0

  class << self
    # Gets the following:
    # - number of stars the project has
    # - raw README.md file
    #
    # Example project's Github url vs raw url
    # - Github: https://github.com/rspec/rspec/blob/master/README.md
    # - Raw: https://raw.githubusercontent.com/rspec/rspec/master/README.md
    #
    # repos: repos whose repo data will be updated
    def update_repo_data(repos = Repository.all)
      repos.each do |repo|
        begin
          @current_repo = repo
          break unless @github_doc.new_doc(@current_repo.url)
          puts "Updated repo #{@current_repo.name}"

          # TODO: add to update_repo_data to get repo name and owner name
          # owner, repo_name = @current_repo.url[/\/\w+\/\w+/].split('/)

          # Parse the page and update repo
          repo.update(stars: repo_stars, watchers: repo_watchers, forks: repo_forks, description: repo_description)
        rescue OpenURI::HTTPError => e
          repo.destroy
          puts "DESTROYED #{@current_repo.name} : its Github URL #{@current_repo.url} resulted in #{e.message}"
        end
      end
    end

    # Retrieves the commits for each Repository
    #
    # NOTE: you can use all options together, but whichever one ends first
    #       will be the one that stops the scraper
    #
    # Options
    # repositories: repos to be scraped for data
    # page_limit: maximum number of pages to iterate
    # user_limit: max number of users to add
    def commits(scrape_limit_opts={}, get_repo_meta=false)
      handle_scrape_limits(scrape_limit_opts)
      catch :scrape_limit_reached do
        @repositories.each do |repo|
          @current_repo = repo
          commits_path = @current_repo.url + '/commits/master'
          puts "Scraping #{repo.name} commits"

          break unless @github_doc.new_doc(commits_path)

          repo.update(watchers: repo_watchers, stars: repo_stars, forks: repo_forks) if get_repo_meta

          catch :recent_commits_finished do
            traverse_commit_pagination
          end
        end
      end
    end

    private
    # this can be added to the other scraper
    def handle_scrape_limits(opts={})
      @repositories = opts[:repositories] || Repository.all
      @page_limit = opts[:page_limit] || Float::INFINITY
      @user_limit = opts[:user_limit] || Float::INFINITY
    end

    def traverse_commit_pagination
      page_count = 1
      loop do
        fetch_commit_data

        throw :scrape_limit_reached if page_count >= @page_limit
        break unless @github_doc.doc.css('.pagination').any?
        page_count += 1

        next_path = @github_doc.doc.css('.pagination a')[0]['href']

        sleep SECONDS_BETWEEN_REQUESTS

        break unless @github_doc.new_doc('https://github.com' + next_path)
      end
    end

    def fetch_commit_data
      @github_doc.doc.css('.commit').each do |commit_info|
        commit_date = Time.parse(commit_info.css('relative-time')[0][:datetime])
        throw :recent_commits_finished unless commit_date.today?

        # Not all avatars are users
        user_anchor = commit_info.css('.commit-avatar-cell a')[0]
        github_username = user_anchor['href'][1..-1] if user_anchor

        if !github_username.nil? && !User.exists?(github_username: github_username)
          user = User.create(github_username: github_username)
          puts "User CREATE github_username:#{user.github_username}"
        elsif !github_username.nil?
          user = User.find_by(github_username: github_username)
        end

        if user
          message = commit_info.css("a.message").text
          github_identifier = commit_info.css("a.sha").text.strip

          unless Commit.exists?(github_identifier: github_identifier)
            Commit.create(
              message: message,
              user: user,
              repository: @current_repo,
              github_identifier: github_identifier
              )
            puts "Commit CREATE identifier:#{github_identifier} by #{user.github_username}"
          end
        end

        throw :scrape_limit_reached if User.count >= @user_limit
      end
    end

    def repo_readme_content
      # NOTE: Only available on the code subpage of the repo
      if @github_doc.doc.at('td span:contains("README")')
        raw_file_url = @current_repo.url.gsub('github', 'raw.githubusercontent') \
                          + '/master/README.md'
        NokoDoc.new_temp_doc(raw_file_url).css('body p').text
      else
        "Empty"
      end
    end

    def select_social_count(child=nil)
      @github_doc.doc.css("ul.pagehead-actions li:nth-child(#{child}) .social-count")
        .text.strip.gsub(',', '').to_i
    end

    def repo_watchers
      select_social_count(1)
    end

    def repo_stars
      select_social_count(2)
    end

    def repo_forks
      select_social_count(3)
    end
  end
end
