class ScraperDispatcher
  def self.scrape_commits
    # refactor this to open a remote redis connection
    loop do
      gem_id = next_gem_id
      GithubScraper.lib_commits(libraries: [ RubyGem.find(gem_id) ])
    end
  end

  private

  def redis
    # TODO: convert to environment variable
    url = '104.236.81.65'
    @redis ||= Redis.new(url: url)
  end

  def next_gem_id
    next_id = redis.lpop('rubygems')
    redis.rpush('rubygems', next_id)
    next_id
  end
end
