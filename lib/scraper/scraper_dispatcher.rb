require_relative '../log_manager/log_manager'

class ScraperDispatcher
  REDIS_ACTIVE_QUEUE_NAME = 'repositories'
  REDIS_BLANK_QUEUE_NAME = 'blank_repositories'

  @current_repo = nil
  @current_action = nil

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


  def self.scrape_metadata
    @log_manager = LogManager.new('metadata')
    repo_activity { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_commits
    @log_manager = LogManager.new('commits')
    repo_activity { GithubRepoScraper.commits(repositories: [@current_repo]) }
  end

  def self.scrape_issues
    @log_manager = LogManager.new('issues')
    repo_activity { GithubRepoScraper.issues(repositories: [@current_repo]) }
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    pw = ENV['REDIS_SERVER_PW']

    @redis ||= Redis.new(
      host: ip,
      password: pw
    )
  end

  def self.time_scraping(start_time)
    "#{((Time.now - start_time) / 60).round(2)} mins"
  end

  def self.repo_activity
    scrape_count = 0
    start_time = Time.now
    @log_manager.log_scraping do
      loop do
        repo_data = JSON.parse(next_repo)
        @current_repo = Repository.find(repo_data['id'])

        yield if block_given?

        scrape_count += 1
        @log_manager.last_activity_log =
          "Last URL Scraped: #{repo_data['url']}.\n" +
          "Scraped #{scrape_count} in #{time_scraping(start_time)}."
      end
    end
  end

  def self.next_repo
    if @log_manager.current_activity == 'metadata'
      queue = REDIS_BLANK_QUEUE_NAME
    else
      queue = REDIS_ACTIVE_QUEUE_NAME
    end
    next_data = redis.lpop(queue)
    redis.rpush(queue, next_data)
    next_data
  end
end
