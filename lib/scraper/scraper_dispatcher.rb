require_relative '../log_manager/log_manager'
require_relative 'github_repo_scraper'
require_relative '../redis/circular_redis_queue'
require_relative '../redis/priority_queue'
require_relative '../redis/redis_queue'

require 'pry'
class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  # TODO: delegate_queue to condense the number of methods between queues
  # TODO: push down or move where enqueue is done

  @current_repo = nil

  def self.prioritized_repos_activity(enqueue: false, query: "stars > 10000", commits_on: true, issues_on: false)
    queue = PriorityQueue.new(enqueue: enqueue, query: query)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end

  def self.scrape_commits(enqueue: false, query: "stars > 10")
    @log_manager = LogManager.new('commits')
    repos = Repository.where(query) if enqueue
    queue = CircularRedisQueue.new(repos, enqueue: enqueue)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo])
    end
  end

  def self.scrape_issues(enqueue: false, query: "stars > 10")
    @log_manager = LogManager.new('issues')
    repos = Repository.where(query) if enqueue
    queue = CircularRedisQueue.new(repos, enqueue: enqueue)
    scraper_handler(queue)  do
      GithubRepoScraper.issues(repositories: [@current_repo])
    end
  end

  def self.update_meta_data(enqueue: false, query: "stars IS_NULL")
    @log_manager = LogManager.new('metadata')
    repos = Repository.where(query) if enqueue
    queue = RedisQueue.new(repos, enqueue: enqueue)
    # TODO: Debug and test the update repo data method on github scraper
    scraper_handler(queue) { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_once(enqueue: false, query: "stars > 10")
    @log_manager = LogManager.new('commits')
    repos = Repository.where("stars > 10") if enqueue
    queue = RedisQueue.new(repos, enqueue: enqueue) if enqueue

    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo])
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

binding.pry
