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
    # TODO: inefficient!
    count = 0
    redis.pipelined do
      Repository.in_batches do |batch|
        batch.each do |repo|
          redis.rpush 'repositories', repo.url
          count += 1
        end
        puts "#{count} repos enqueued"
      end
    end
    # Repository.all.each do |repo|
    #   redis.rpush('repositories', repo.id)
    #   count += 1
    # end
  end

  private

  def self.redis
    ip = ENV['REDIS_SERVER_IP']
    @redis ||= Redis.new(host: ip)
  end

  def self.next_repo_id
    next_url = redis.lpop('repositories')
    redis.rpush('repositories', next_url)
    next_id
  end
end
