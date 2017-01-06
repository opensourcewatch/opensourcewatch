require_relative './noko_doc'

# Scrapes data for Repositories and Users on Github.com
class GithubScraper
  @github_doc = NokoDoc.new
  @current_lib = nil
  @SECONDS_BETWEEN_REQUESTS = 0

  class << self
    attr_reader :github_doc # TODO: is this needed?
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
          @current_lib = repo
          break unless @github_doc.new_doc(@current_lib.url)
          puts "Updated repo #{@current_lib.name}"

          # TODO: add to update_repo_data to get repo name and owner name
          # owner, repo_name = @current_lib.url[/\/\w+\/\w+/].split('/)

          # Parse the page and update repo
          repo.update(stars: repo_stars, description: repo_description)
        rescue OpenURI::HTTPError => e
          repo.destroy
          puts "DESTROYED #{@current_lib.name} : its Github URL #{@current_lib.url} resulted in #{e.message}"
        end
      end
    end

    # Retrieves the commits for each Repository
    #
    # NOTE: you can use all options together, but whichever one ends first
    #       will be the one that stops the scraper
    #
    # Options
    # libraries: libraries whose repos will be scraped for data
    # page_limit: maximum number of pages to iterate
    # user_limit: max number of users to add
    # TODO: expand rake task to pass in these options
    def lib_commits(scrape_limit_opts={})
      handle_scrape_limits(scrape_limit_opts)
      catch :scrape_limit_reached do
        @repositories.each do |lib|
          @current_lib = lib
          commits_path = @current_lib.url + '/commits/master'

          puts "Scraping #{lib.name} commits"

          break unless @github_doc.new_doc(commits_path)

          catch :recent_commits_finished do
            traverse_commit_pagination
          end

          # TODO: why is this here?
          @page_limit
        end
      end
    end

    # 2 agents for user data and stars/followers data
    def update_user_data
      User.all.each do |user|
        break unless @github_doc.new_doc("https://github.com/#{user.github_username}")
        followers = @github_doc.doc.css('a[href="/#{user.github_username}?tab=followers .counter"]').text.strip
        name = @github_doc.doc.css('.vcard-fullname').text.strip

        personal_repos_doc = NokoDoc.new_temp_doc("https://github.com/#{user.github_username}?page=1&tab=repositories")
        break unless personal_repos_doc
        personal_star_count = 0
        pagination_count = 1

        loop do
          personal_repos_doc.css('a[aria-label="Stargazers"]').each do |star_count|
            personal_star_count += star_count.text.strip.to_i
          end

          break if personal_repos_doc.css('.next_page.disabled').any?

          pagination_count += 1
          page_regex = /page=#{pagination_count}/

          personal_repos_doc = NokoDoc.new_temp_doc("https://github.com/#{user.github_username}?page=1&tab=repositories".gsub(/page=\d/, "page=#{pagination_count}"))
          break unless personal_repos_doc
        end

        User.update(user.id,
                    name: name,
                    followers: followers,
                    stars: personal_star_count)
      end
    end

    private

    # Avoid looking too robotic to Github
    def random_sleep
      sleep [3].sample
    end

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
              repository: @current_lib,
              github_identifier: github_identifier
              )
            puts "Commit CREATE identifier:#{github_identifier} by #{user.github_username}"
          end
        end

        throw :scrape_limit_reached if User.count >= @user_limit
      end
    end

    def repo_description
      if @github_doc.doc.at('td span:contains("README")')
        raw_file_url = @current_lib.url.gsub('github', 'raw.githubusercontent') \
                          + '/master/README.md'
        NokoDoc.new_temp_doc(raw_file_url).css('body p').text
      else
        "Empty"
      end
    end

    def repo_stars
      @github_doc.doc.css('ul.pagehead-actions li:nth-child(2) .social-count')
        .text.strip.gsub(',', '').to_i
    end
  end
end
