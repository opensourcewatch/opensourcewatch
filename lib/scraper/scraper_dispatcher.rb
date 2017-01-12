require_relative '../queue/redis_wrapper'
require_relative 'github_repo_scraper'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  @current_repo = nil
  @redis_wrapper = RedisWrapper.new

  # TODO: refactor rake tasks
  # TODO: Add a pathway to scrape repos based on the prioritized queue

  def self.scrape(queue_name: RedisWrapper::REDIS_ACTIVE_QUEUE_NAME, issues_on: false)
    if queue_name == RedisWrapper::REDIS_ACTIVE_QUEUE_NAME
      scraper_handler(queue_name) do
        GithubRepoScraper.commits(repositories: [@current_repo])
        GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
      end
    elsif queue_name == RedisWrapper::REDIS_BLANK_QUEUE_NAME
      # TODO: Debug and test
      scraper_handler(queue_name) { GithubRepoScraper.update_repo_data([@current_repo]) }
    else
      raise "That queue name does not exist. Exiting Dispatcher."
    end
  end

  private

  def self.scraper_handler(queue_name)
    start_time = Time.now
    scrape_count = 0

    loop do
      repo_data = JSON.parse(@redis_wrapper.next_repo(queue_name))

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"

      yield if block_given?

      scrape_count += 1
      puts "Scraped #{scrape_count} in #{((Time.now - start_time) / 60).round(2)} mins"
    end
  end
end
