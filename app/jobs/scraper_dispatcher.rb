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

  def self.scrape(job: "commits", queue_name: nil, queue_type: "circular", repo_update: false)
    @log_manager = LogManager.new(job)

    queue = create_queue(queue_type, name: queue_name)
    scraper_handler(queue) do
      GithubRepoScraper.send(job, { repositories: [@current_repo] }, repo_update)
    end
  end

  # Only advantage over repo update above is it also grabs README
  def self.update_meta_data(queue_name: nil)
    @log_manager = LogManager.new('metadata')
    queue = RedisQueue.new(name: queue_name)
    scraper_handler(queue) { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.enqueue(query: "stars > 10", limit: 100_000, type: "normal", name: nil)
    repos = Repository.where(query).limit(limit)

    create_queue(type, repos: repos, name: name, enqueue: true)
  end

  private

  def self.create_queue(type, repos: nil, name: nil, enqueue: false)
    case type
    when "normal"
      RedisQueue.new(repos, queue_name: name, enqueue: enqueue)
    when "priority"
      PriorityQueue.new(repos, queue_name: name, enqueue: enqueue, rescore: true)
    when "circular"
      CircularRedisQueue.new(repos, queue_name: name, enqueue: enqueue)
    else
      raise Exception.new("Invalid queue type")
    end
  end

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
