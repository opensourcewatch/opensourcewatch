require_relative 'redis_queue'

# Virtual model to manage the prioritized redis queue
class CircularRedisQueue < RedisQueue

  def initialize(repos = nil, queue_name = nil)
    @redis = RedisWrapper.new.redis
    @queue_name = queue_name || ENV['REDIS_CIRCULAR_QUEUE_NAME']
    @repos = repos # Only needed for enqueing
  end

  def next
    next_repo = @redis.lpop @queue_name
    @redis.rpush @queue_name, next_repo
    JSON.parse(next_repo)
  end
end
