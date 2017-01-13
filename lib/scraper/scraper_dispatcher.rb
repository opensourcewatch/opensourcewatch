require_relative '../queue/redis_wrapper'
require_relative 'github_repo_scraper'

class ScraperDispatcher
  # Dispatches scrapers to use various redis queues and scrape for different
  # types of data

  @current_repo = nil
  @redis_wrapper = RedisWrapper.new

  def self.scrape(queue_name: RedisWrapper::REDIS_ACTIVE_QUEUE_NAME, commits_on: true, issues_on: false)
    if queue_name == RedisWrapper::REDIS_ACTIVE_QUEUE_NAME
      scraper_handler(queue_name) do
        GithubRepoScraper.commits(repositories: [@current_repo]) if commits_on
        GithubRepoScraper.issues(repositories: [@current_repo]) if issues_on
      end
    elsif queue_name == RedisWrapper::REDIS_PRIORITY_QUEUE_NAME
      priority_scraper_handler(queue_name)
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
      # TODO: dispatcher should work directly with a queue that uses redis underneath,
      # not the other way around
      repo_data = @redis_wrapper.next_repo(queue_name)

      @current_repo = Repository.find(repo_data['id'])

      puts "Scraping: #{repo_data['url']}"

      yield if block_given?

      scrape_count += 1
      puts "Scraped #{scrape_count} in #{((Time.now - start_time) / 60).round(2)} mins"
    end
  end

  def self.priority_handler
    unique_queues = generate_queues

    # add them to a skewed distribution list
      # n! elements in queue
    queues = skewed_dist_of_queues(unique_queues)

    loop do
      # get leftmost queue and push to the end
      queue = queues.shift
      queues.push(queue)

      @current_repo = Repository.find(queue.next['id'])

      GithubRepoScraper.commits(repositories: [@current_repo])
    end
  end

  def self.generate_queues
    priority_tags = RedisWrapper::PRIORITY_RANGE
    base_queue_name = RedisWrapper::REDIS_PRIORITY_QUEUE_NAME

    unique_queues = []
    priority_tags.each do |tag|
      queue_name = base_queue_name + '_' + tag.to_s
      unique_queues << CircularRedisQueue.new(@redis_wrapper.redis, queue_name)
    end
    unique_queues
  end

  def self.skewed_dist_of_queues(queues)
    # Want to create a distribution like:
    #   [3, 2, 1] + [3, 2] + [3]
    skewed_dist_of_queues = []
    while queues.length > 0
      queues.each do |queue|
        skewed_dist_of_queues << queue
      end
      queues.pop
    end
    skewed_dist_of_queues
  end
end

binding.pry
