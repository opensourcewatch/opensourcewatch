require_relative 'github_repo_scraper'
require_relative '../redis/circular_redis_queue'
require_relative '../redis/priority_queue'
require_relative '../redis/redis_queue'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  @current_repo = nil

  def self.prioritized_repos_activity(enqueue: false, query: "stars > 10000", limit: 100_000, commits_on: true, issues_on: false)
    repos = Repository.where(query).limit(limit)
    queue = PriorityQueue.new(repos, enqueue: enqueue)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end

  def self.repos_activity(enqueue: false, query: "stars > 10", limit: 100_000, commits_on: true, issues_on: false)
    repos = Repository.where(query).limit(limit)
    queue = CircularRedisQueue.new(repos, enqueue: enqueue)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end

  def self.update_meta_data(enqueue: false, query: "stars IS NULL", limit: 100_000)
    repos = Repository.where(query).limit(limit)
    queue = RedisQueue.new(repos, enqueue: enqueue)
    scraper_handler(queue) { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  private

  def self.scraper_handler(queue)
    start_time = Time.now
    scrape_count = 0

    loop do
      repo_data = queue.next

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"

      yield if block_given?

      scrape_count += 1
      puts "Scraped #{scrape_count} in #{((Time.now - start_time) / 60).round(2)} mins"
    end
  end
end
