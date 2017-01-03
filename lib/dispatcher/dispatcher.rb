require 'redis'

class Dispatcher
  # New Redis connection
  # Assumes default configuration of localhost:6379
  @redis = Redis.new
  class << self
    # queueing
    def enqueue_all
      RubyGem.all.each do |gem|
        @redis.rpush('rubygems', gem.id)
      end
    end

    def circular_queue
      loop do
        current_id = @redis.lpop('rubygems')
        @redis.rpush('rubygems', current_id)
        curr_gem = RubyGem.find(current_id)
        GithubScraper.lib_commits(libraries: [curr_gem])
      end
    end
  end
end
