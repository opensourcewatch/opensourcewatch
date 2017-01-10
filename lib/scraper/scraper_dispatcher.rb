class ScraperDispatcher
  REDIS_ACTIVE_QUEUE_NAME = 'repositories'
  REDIS_BLANK_QUEUE_NAME = 'blank_repositories'

  @current_repo = nil

  def self.scrape_metadata
    repo_significance { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_commits
    repo_activity { GithubRepoScraper.commits(repositories: [@current_repo]) }
  end

  def self.scrape_issues
    repo_activity { GithubRepoScraper.issues(repositories: [@current_repo]) }
  end

  def self.redis_requeue(queue_name: REDIS_ACTIVE_QUEUE_NAME, query: "stars > 10")
    redis.del queue_name

    start_time = Time.now
    count = 0
    redis.pipelined do
      Repository.where(query).in_batches do |batch|
        puts "Enqueuing #{queue_name}"
        batch.each do |repo|
          redis.rpush queue_name,{
            id: repo.id,
            url: repo.url
          }.to_json
        end
        count += 1000
        puts "#{count} repos enqueued"
      end
    end
    puts "#{redis.llen queue_name} were enqueued in #{((Time.now - start_time) / 60).round(2)} mins"
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    @redis ||= Redis.new(host: ip)
  end

  def self.next_active_repo
    next_data = redis.lpop(REDIS_ACTIVE_QUEUE_NAME)
    redis.rpush(REDIS_ACTIVE_QUEUE_NAME, next_data)
    next_data
  end

  def self.next_blank_repo
    redis.lpop(REDIS_BLANK_QUEUE_NAME)
  end

  # TODO: refactor ? repo_activity and repo significance are almost identical
  def self.repo_activity
    start_time = Time.now
    scrape_count = 0
    queue_length = redis.llen(REDIS_ACTIVE_QUEUE_NAME).to_i

    loop do
      repo_data = JSON.parse(next_active_repo)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"

      yield if block_given?

      scrape_count += 1
      puts "Scraped #{scrape_count}/#{queue_length} in #{((Time.now - start_time) / 60).round(2)} mins"
    end
  end

  def self.repo_significance
    start_time = Time.now
    scrape_count = 0
    binding.pry
    queue_length = redis.llen(REDIS_BLANK_QUEUE_NAME).to_i

    loop do
      repo_data = JSON.parse(next_blank_repo)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"
      yield if block_given?
      puts "Scraped #{scrape_count} our of #{queue_length} in #{((Time.now - start_time) / 60).round(2)} mins"

      scrape_count += 1
    end
  end
end
