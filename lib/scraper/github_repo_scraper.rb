require_relative './noko_doc'

# Scrapes data for Repositories and Users on Github.com
class GithubRepoScraper
  @github_doc = NokoDoc.new
  @current_repo = nil
  SECONDS_BETWEEN_REQUESTS = 0
  @BASE_URL = "https://github.com"

  # TODO: add check so that these methods don't necessarily take and active record
  # model, because we don't want to hit the db everytime in the dispatcher
  # TODO: we could pass in a shallow repository model and only actually find the model
  # if we need to associate a commit, or actually do an update etc.
  class << self
    # Gets the following:
    # - number of stars the project has
    # - raw README.md file
    #
    # Example project's Github url vs raw url
    # - Github: https://github.com/rspec/rspec/blob/master/README.md
    # - Raw: https://raw.githubusercontent.com/rspec/rspec/master/README.md
    def update_repo_data(repos = Repository.all)
      repos.each do |repo|
        begin
          break unless get_repo_doc(repo)

          # TODO: add to update_repo_data to get repo name and owner name
          # owner, repo_name = @current_repo.url[/\/\w+\/\w+/].split('/)

          update_repo_meta(false)
          puts "Updated repo #{@current_repo.name}"

        rescue OpenURI::HTTPError => e
          repo.destroy
          puts "DESTROYED #{@current_repo.name} : its Github URL #{@current_repo.url} resulted in #{e.message}"
        end
      end
    end

    # Retrieves the open issues and comments for each repository
    def issues(scrape_limit_opts={}, get_repo_meta=false)
      handle_scrape_limits(scrape_limit_opts)

      @repositories.each do |repo|
        break unless get_repo_doc(repo, "/issues")

        update_repo_meta if get_repo_meta

        puts "Scraping issues for #{repo.name}"
        issues = [] # cache issues so we can cycle through without hitting the db
        loop do
          # Get all the issues from page
          raw_issues = @github_doc.doc.css("div.issues-listing ul li div.d-table")

          raw_issues.each do |raw_issue|
            issue = Issue.create( build_issue(raw_issue) )
            puts "Creating Issue" if issue.id

            issues << issue
          end

          next_url_anchor = @github_doc.doc.css("a.next_page")
          if next_url_anchor.present?
            next_url_rel_path = next_url_anchor.attribute("href").value
            @github_doc.new_doc(@BASE_URL + next_url_rel_path)
          else
            break
          end
        end

        # Get all the comments for each issue
        issues.each do |issue|
          doc_path = @BASE_URL + issue.url
          @github_doc.new_doc(doc_path)

          raw_comments = @github_doc.doc.css("div.timeline-comment-wrapper")

          raw_comments.each do |raw_comment|
            comment_json = build_comment(raw_comment)
            comment_json['issue_id'] = issue

            issue_comment = IssueComment.create(comment_json)
            puts "Creating Issue Comment" if issue_comment
          end
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
          break unless get_repo_doc(repo, "/commits")

          update_repo_meta if get_repo_meta

          puts "Scraping #{repo.name} commits"
          catch :recent_commits_finished do
            traverse_commit_pagination
          end
        end
      end
    end

    private

    # TODO: we should cache all the users for a repo when a repo is requested, so
    # we don't have to hit the DB as often, because I'll have to get the name
    # of the user from the comment, search if it exist, then create it.
    # If we had them cached I could search those, if not found, create it.
    # Basically let's make that query when we get the repo.
    def build_comment(raw_comment)
      user_name = raw_comment.css("a.author").text
      user = User.find_by(github_username: user_name)
      unless user
        puts "Creating new user: #{user_name}"
        user = User.create(github_username: user_name)
      end

      comment_json = {}
      comment_json['user_id'] = user.id
      comment_json['github_created_at'] = raw_comment.css("a relative-time").attribute("datetime").value
      comment_json['body'] = raw_comment.css("td.comment-body").text
      comment_json
    end

    def build_issue(raw_issue)
      issue = {}
      issue['repository_id'] = @current_repo.id

      issue['name'] = raw_issue.css("a.h4").text.strip
      issue['creator'] = raw_issue.css("a.h4")
      issue['url'] = raw_issue.css("a.h4").attribute("href").value

      issue_number, open_date, creator = raw_issue.css("span.opened-by").text.strip.split("\n")

      issue['issue_number'] = issue_number[1..-1].to_i
      issue['creator'] = creator.strip
      issue['open_date'] = open_date.split(" ")[1..-2].join(" ")

      issue
    end

    def get_repo_doc(repo, path="")
      @current_repo = repo
      # TODO: consider making a psuedo object to pass around
      doc_path = @current_repo.url + path
      return @github_doc.new_doc(doc_path)
    end

    def update_repo_meta(get_readme = false)
      if get_readme
        readme_content = repo_readme_content
      else
        readme_content = nil
      end
      # Grab general meta data that is available on the commits page
      # if told to do so
      @current_repo.update(
        watchers: repo_watchers,
        stars: repo_stars,
        forks: repo_forks,
        open_issues: repo_open_issues,
        readme_content: readme_content
        )
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

        break unless @github_doc.new_doc(@BASE_URL + next_path)
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
        raw_file_url = @current_repo.url.gsub('github', 'raw.githubusercontent' +
                          '/master/README.md')
        NokoDoc.new_temp_doc(raw_file_url).css('body p').text
      else
        nil
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

    def repo_open_issues
      @github_doc.doc.css("a.reponav-item span:nth-child(2).counter").text.to_i
    end
  end
end
