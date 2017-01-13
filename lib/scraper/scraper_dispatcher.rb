require_relative 'github_repo_scraper'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  @current_repo = nil
  @redis_wrapper = RedisWrapper.new
  
  def self.scrape_repos(commits_on: true, issues_on: false)
    queue = CircularRedisQueue.new(@redis_wrapper.redis)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end

  def self.scrape_prioritized_repos(commits_on: true, issues_on: false)
    queue = PriorityQueue.new(@redis_wrapper.redis)
    scraper_handler(queue) do
      GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
      GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
    end
  end

  def self.scrape_blank_repos
    # TODO: Debug and test
    queue = RedisQueue.new(@redis_wrapper.redis, queue_name)
    scraper_handler(queue_name) { GithubRepoScraper.update_repo_data([@current_repo]) }
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
