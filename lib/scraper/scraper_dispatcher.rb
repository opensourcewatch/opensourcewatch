class ScraperDispatcher
  @current_repo = nil

  def self.repo_activity(opts = {})
    # TODO: refactor this to batch jobs
    @start_time = Time.now
    @scrape_count = 0
    queue_length = redis.llen('repositories').to_i

    loop do
      repo_data = JSON.parse(next_repo_data)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"
      yield if block_given?
      puts "Scraped #{@scrape_count} in #{((Time.now - @start_time) / 60).round(2)} mins"

      @scrape_count += 1
      break if @scrape_count >= queue_length
    end
  end

  def self.scrape_metadata
    repo_activity { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_commits
    repo_activity { GithubRepoScraper.commits(repositories: [@current_repo]) }
  end

  def self.scrape_issues
    repo_activity { GithubRepoScraper.issues(repositories: [@current_repo]) }
  end

  def self.redis_requeue
    redis.del 'repositories'

    start_time = Time.now
    count = 0
    redis.pipelined do
      Repository.where('stars > 10').in_batches do |batch|
        batch.each do |repo|
          redis.rpush 'repositories',{
            id: repo.id,
            url: repo.url
          }.to_json
        end
        count += 1000
        puts "#{count} repos enqueued"
      end
    end
    puts "#{redis.llen 'repositories'} were enqueued in #{((Time.now - start_time) / 60).round(2)} mins"
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    @redis ||= Redis.new(host: ip)
  end

  def self.next_repo_data
    next_data = redis.lpop('repositories')
    redis.rpush('repositories', next_data)
    next_data
  end
end
