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
        puts "Out of requests... Sleeping"
        puts "Beginning at #{time_to_reset}"

        wait = Time.at(time_to_reset) - Time.now
        sleep wait unless wait.negative?
      end
    end

    private

    def upsert_lib(repo)
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

    def query(param)
      @query = "?q=''&q=#{param}&sort=stars&order=desc"
    end

    def last_pagination?
      !@resp.headers['link'].include?('rel="last"')
    end

    def handle_request
      if last_pagination? && last_repo_already_stored?
        puts "Aborting due to repeating loop"
        abort
      elsif last_pagination?
        last_stars = Repository.last.stars
        @current_url = @BASE_URL + query("stars:<=#{last_stars}")
      else
        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
      end

      parse_repos
    end

    def last_repo_already_created?
      Repository.find_by("github_id=#{JSON.parse(@resp.body)['items'].last['id']}")
    end

    def parse_repos
      JSON.parse(@resp.body)['items'].each do |repo_hash|
        upsert_lib(repo_hash)
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
