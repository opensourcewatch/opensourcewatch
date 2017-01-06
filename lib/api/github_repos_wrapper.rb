class GithubReposWrapper
  @BASE_URL = 'https://api.github.com/repositories'
  @access_token = ENV["GITHUB_API_KEY"]

  class << self
    def paginate_repos(last_id_seen = '0')
      # Set initial kickoff url to paginate from
      @current_url = @BASE_URL + query(last_id_seen)
      # Rate limiting
      loop do
        # Pagination
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

    def create_repos
      puts "Upserting Repository."
      Repository.create(@repos)
      # Repository.create(github_id: repo['id'],
      #                   name: repo['name'],
      #                   url: repo['html_url'],
      #                   language:  repo['language'],
      #                   stars:  repo['stargazers_count'],
      #                   forks: repo['forks']
      # )
      puts "Repository Upserted"
    end

    def query(id)
      @query = "?since=#{id}"
    end

    def handle_request
        parse_repos

        @current_url = @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
    end

    def parse_repos
      @repos = JSON.parse(@resp.body).map do |repo|
        {
          github_id: repo['id'],
          name: repo['name'],
          url: repo['html_url'],
          language:  repo['language'],
          stars:  repo['stargazers_count'],
          forks: repo['forks']
        }
      end
      create_repos
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
