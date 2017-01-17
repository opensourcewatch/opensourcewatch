require_relative 'redis_queue'

# Virtual model to manage the prioritized redis queue
class CircularRedisQueue < RedisQueue

  # TODO: almost identical to parent--can we refactor?
  def initialize(repos = nil, queue_name: ENV['REDIS_CIRCULAR_QUEUE_NAME'], enqueue: false)
    @redis = RedisWrapper.new.redis
    @queue_name = queue_name
    @repos = repos # Only needed for enqueing

    enqueue_redis if enqueue
  end

  def next
    next_repo = @redis.lpop @queue_name
    @redis.rpush @queue_name, next_repo
    JSON.parse(next_repo)
  end
end
