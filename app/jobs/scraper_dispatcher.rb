require_relative '../../lib/log_manager/log_manager'
require_relative 'github_repo_scraper'
require_relative 'circular_redis_queue'
require_relative 'priority_queue'
require_relative 'redis_queue'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  # TODO: delegate_queue to condense the number of methods between queues
  # TODO: push down or move where enqueue is done

  @current_repo = nil

  def self.prioritized_repos_activity
    queue = PriorityQueue.new
    
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end


  def self.scrape_commits
    @log_manager = LogManager.new('commits')
    queue = CircularRedisQueue.new
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo])
    end
  end

  def self.scrape_issues
    @log_manager = LogManager.new('issues')

    queue = CircularRedisQueue.new
    scraper_handler(queue)  do
      GithubRepoScraper.issues(repositories: [@current_repo])
    end
  end


  def self.update_meta_data
    @log_manager = LogManager.new('metadata')
    queue = RedisQueue.new
    scraper_handler(queue) { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_once
    @log_manager = LogManager.new('commits')
    queue = RedisQueue.new

    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo])
    end
  end

  def self.enqueue(query: "stars > 10", limit: 100_000, type: "normal")
    repos = Repository.where(query).limit(limit)

    if type == "normal"
      RedisQueue.new(repos, enqueue: true)
    elsif type == "priority"
      PriorityQueue.new(repos, enqueue: true)
    elsif type == "circular"
      CircularRedisQueue.new(repos, enqueue: true)
    else
      raise Exception.new("Invalid queue type")
    end
  end

  private

  def self.scraper_handler(queue)
    start_time = Time.now
    scrape_count = 0
    @log_manager.log_scraping do
      loop do
        repo_data = queue.next

        @current_repo = Repository.find(repo_data['id'])

        puts "Scraping: #{repo_data['url']}"

        yield if block_given?

        scrape_count += 1
        @log_manager.last_activity_log =
          "Last URL Scraped: #{repo_data['url']}.\n" +
          "Scraped #{scrape_count} in #{time_scraping(start_time)}."
        puts @log_manager.last_activity_log
      end
    end
  end

  def self.time_scraping(start_time)
    "#{((Time.now - start_time) / 60).round(2)} mins"
  end
end
