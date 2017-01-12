require_relative '../queue/redis_wrapper'
require_relative 'github_repo_scraper'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  @current_repo = nil
  @redis_wrapper = RedisWrapper.new

  # TODO: Add a pathway to scrape repos based on the prioritized queue
  # TODO: refactor rake tasks

  # TODO: Debug and test
  def self.scrape_metadata
    repo_significance { GithubRepoScraper.update_repo_data([@current_repo]) }
  end

  def self.scrape_commits
    repo_activity { GithubRepoScraper.commits(repositories: [@current_repo]) }
  end

  def self.scrape_issues
    repo_activity { GithubRepoScraper.issues(repositories: [@current_repo]) }
  end

  private

  # TODO: refactor ? repo_activity and repo significance are almost identical
  def self.repo_activity
    start_time = Time.now
    scrape_count = 0

    loop do
      repo_data = JSON.parse(@redis_wrapper.next_active_repo)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"

      yield if block_given?

      scrape_count += 1
      puts "Scraped #{scrape_count} in #{((Time.now - start_time) / 60).round(2)} mins"
    end
  end

  def self.repo_significance
    start_time = Time.now
    scrape_count = 0

    loop do
      repo_data = JSON.parse(@redis_wrapper.next_blank_repo)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"
      yield if block_given?
      puts "Scraped #{scrape_count} in #{((Time.now - start_time) / 60).round(2)} mins"

      scrape_count += 1
    end
  end
end

binding.pry
