class GithubSearchWrapper
  @BASE_URL = 'https://api.github.com/search/repositories'
  @access_token = ENV["GITHUB_API_KEY"]

  class << self
    def paginate_repos(query_param = 'stars:>1')
      # Set initial kickoff url to paginate from
      @current_url = @BASE_URL + query(query_param)
      loop do
        loop do
          @resp = search_request
          puts "Search request to #{@current_url}"

          rate_requests_remain? ? handle_request : break
        end
        wait_time = time_to_reset - Time.now

        puts "Out of requests... Sleeping ~#{wait_time} s"
        puts "Beginning at ~#{Time.at(time_to_reset)}"

        sleep wait_time unless wait_time.negative?
      end
    end

    private

    def handle_request
      @parsed_repos = JSON.parse(@resp.body)['items']
      @first_repo_stars_of_first_pagination = @parsed_repos.first['stargazers_count'] if first_pagination?

      upsert_repos

      if repeat_pagination?
        puts "Aborting due to repeating loop"
        abort
      elsif last_pagination?
        last_stars = @parsed_repos.last['stargazers_count']
        @current_url = @BASE_URL + query("stars:<=#{last_stars}")
      else
        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      end
    end

    def query(param)
      @query = "?q=''&q=#{param}&sort=stars&order=desc"
    end

    def first_pagination?
      !@resp.headers['link'].include?('rel="first"')
    end

    def repeat_pagination?
      last_pagination? && first_and_last_repo_star_count_equal?
    end

    def last_pagination?
      !@resp.headers['link'].include?('rel="last"')
    end

    def first_and_last_repo_star_count_equal?
      @parsed_repos.last['stargazers_count'] == @first_repo_stars_of_first_pagination
    end

    def upsert_repos
      @parsed_repos.each do |repo|
        puts "Upserting Repository."
        Repository.find_or_create_by(github_id: repo['id']) do |repository|
          repository.name = repo['name']
          repository.github_id = repo['id']
          repository.url = repo['html_url']
          repository.language = repo['language']
          repository.stars = repo['stargazers_count']
          repository.forks = repo['forks']
        end
        puts "Repository Upserted"
      end
    end

    def search_request
      Faraday.get(@current_url) do |req|
        req.headers['Authorization'] = "token #{@access_token}"
        req.headers['Accept'] = 'application/vnd.github.v3+json'
      end
    end

    def rate_requests_remain?
      requests_remaining > 0
    end

    def requests_remaining
      @resp.headers['x-ratelimit-remaining'].to_i
    end

    def time_to_reset
      @resp.headers['x-ratelimit-reset'].to_i
    end
  end
end
