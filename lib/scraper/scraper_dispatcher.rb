class ScraperDispatcher
  def self.scrape_commits
    # TODO: refactor this to open a remote redis connection
    loop do
      repo_id = next_repo_id
      GithubScraper.lib_commits(libraries: [ Repository.find(repo_id) ])
    end
  end

  def self.redis_requeue
    redis.flushall
    Repository.all.each do |repo|
      redis.rpush('repositories', repo.id)
    end
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    @redis ||= Redis.new(host: ip)
  end

  def self.next_repo_id
    next_id = redis.lpop('repositories')
    redis.rpush('repositories', next_id)
    next_id
  end
end
