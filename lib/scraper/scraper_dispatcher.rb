class ScraperDispatcher
  @current_repo = nil

  def self.repo_activity
    # TODO: refactor this to batch jobs
    @start_time = Time.now
    @scrape_count = 0
    queue_length = redis.llen('repositories').to_i

    loop do
      repo_url = next_repo_url

      @current_repo = Repository.where("url='#{repo_url}'").first

      puts "Scraping: #{repo_url}"
      scrape_commits
      scrape_issues
      puts "Scraped #{@scrape_count} in #{((Time.now - @start_time) / 60).round(2)} mins"

      @scrape_count += 1
      break if @scrape_count >= queue_length
    end
  end

  def self.scrape_commits
    GithubRepoScraper.commits(repositories: [@current_repo])
  end

  def self.scrape_issues
    GithubRepoScraper.issues(repositories: [@current_repo])
  end

  def self.redis_requeue
    redis.del 'repositories'

    start_time = Time.now
    count = 0
    redis.pipelined do
      Repository.where('stars > 10').in_batches do |batch|
        batch.each do |repo|
          redis.rpush 'repositories',{
            id: repo.id,
            url: repo.url
          }
        end
        count += 1000
        puts "#{count} repos enqueued"
      end
    end
    puts "#{redis.llen 'repositories'} were enqueued in #{((Time.now - start_time) / 60).round(2)} mins"
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    @redis ||= Redis.new(host: ip)
  end

  def self.next_repo_url
    next_url = redis.lpop('repositories')
    redis.rpush('repositories', next_url)
    next_url
  end
end
