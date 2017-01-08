class ScraperDispatcher
  def self.scrape_commits
    # TODO: refactor this to scrape in batches
    loop do
      repo_url = next_repo_url
      GithubRepoScraper.commits(libraries: [ Repository.where("url='#{repo_url}'") ])
    end
  end

  def self.redis_requeue
    redis.del 'repositories'

    start_time = Time.now
    count = 0
    redis.pipelined do
      Repository.where('stars > 10').in_batches do |batch|
        batch.each do |repo|
          redis.rpush 'repositories', repo.url
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
