class GithubReposWrapper
  BASE_URL = 'https://api.github.com/repositories'
  BATCHES_TO_MERGE = 10 # Each batch has 100 records (from githubs api), this says merge X batches per insert

  @access_token = ENV["GITHUB_API_KEY"]
  @stop_id = nil
  @repos = []

  class << self
    # stop_id: compares the stop_id with next_id and doesn't make anymore
    # =>       requests if next_id >= stop_id
    def paginate_repos(start_id: '0', stop_id: nil)
      @stop_id = stop_id.to_i if stop_id
      # Set initial kickoff url to paginate from
      @current_url = BASE_URL + query(start_id)
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

    def handle_request
        # TODO: We can speed this up by saving more records, say 1000 in memory before importing to the database
        repos_batch = parse_repos
        @repos << repos_batch

        create_repos if @repos.length >= BATCHES_TO_MERGE

        next_url =  @resp.headers['link'].split(',').first.split(';').first[/(?<=<).*(?=>)/]
        next_id = next_url.split('=').last.to_i
        if @stop_id && @stop_id < next_id
          puts "Stopping requests and exiting: stop limit reached at id:#{next_id}"
          abort
        end
        @current_url = next_url
    end

    def parse_repos
      return  JSON.parse(@resp.body).map do |repo|
        Repository.new({
          github_id: repo['id'],
          name: repo['name'],
          url: repo['html_url'],
          language:  repo['language'],
          stars:  repo['stargazers_count'],
          forks: repo['forks']
        })
      end
    end

    def create_repos
      @repos.flatten!
      puts "Creating Repositories."
      time_to_execute do
        Repository.import(@repos)
      end
      puts "Clearing in memory repos"
      @repos = []
    end

    def query(id)
      @query = "?since=#{id}"
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

    def time_to_execute
      start_time = Time.now
      yield
      puts "Executed in #{Time.now - start_time}"
    end
  end
end
