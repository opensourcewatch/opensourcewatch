class GithubSearchWrapper
  @BASE_URL = 'https://api.github.com/search/repositories'
  @access_token = ENV["GITHUB_API_KEY"]
  @repos_processed = 0

  class << self
    def paginate_repos(query_param = 'stars:>1')
      # Set initial kickoff url to paginate from
      @start_time = Time.now
      @current_url = @BASE_URL + query(query_param)
      loop do
        loop do
          @resp = search_request
          puts "Search request to #{@current_url}"

          rate_requests_remain? ? handle_request : break
        end

        wait_time = Time.at(seconds_to_reset) - Time.now

        if abuse_error?
          puts "Sleeping due to abuse error"
          sleep @resp.headers['retry-after'].to_i
          next
        end

        puts "Time until reset: #{Time.at(seconds_to_reset)}"
        puts "Current time: #{Time.now.to_s}"

        puts "Out of requests... Sleeping ~#{wait_time} s"

        sleep wait_time unless wait_time.negative?
      end
    end

    private

    def handle_request
      @parsed_repos = JSON.parse(@resp.body)['items']
      @first_repo_stars_of_first_pagination = @parsed_repos.first['stargazers_count'] if first_pagination?

      process_repos

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

    def process_repos
      puts "Processing 30 Repositories."
      repos = @parsed_repos.map do |repo|
        Repository.new({
          name: repo['name'],
          github_id: repo['id'],
          url: repo['html_url'],
          language: repo['language'],
          stars:  repo['stargazers_count'],
          forks:  repo['forks']
        })
      end
      Repository.import(repos)
      puts "#{@repos_processed += 30} Repositories Processed in #{minutes_running} minutes."
    end

    def minutes_running
      ((Time.now - @start_time) / 60).round(2)
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

    def seconds_to_reset
      @resp.headers['x-ratelimit-reset'].to_i
    end

    def abuse_error?
      seconds_to_reset == 0
    end
  end
end
