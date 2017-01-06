# TODO: modify to reflect drop of ruby gems table
class ScraperDispatcher
  def self.scrape_commits
    # refactor this to open a remote redis connection
    loop do
      gem_id = next_gem_id
      GithubScraper.lib_commits(libraries: [ RubyGem.find(gem_id) ])
    end
  end

  def self.redis_requeue
    redis.flushall
    RubyGem.all.each do |gem|
      redis.rpush('rubygems', gem.id)
    end
  end

  private

  def self.redis
    # TODO: convert to environment variable
    ip = '104.236.81.65'
    @redis ||= Redis.new(host: ip)
  end

  def self.next_gem_id
    next_id = redis.lpop('rubygems')
    redis.rpush('rubygems', next_id)
    next_id
  end
end
