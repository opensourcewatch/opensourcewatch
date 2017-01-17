# Virtual model to manage the prioritized redis queue
class CircularRedisQueue < RedisQueue
  DEFAULT_QUEUE_NAME = ENV['REDIS_CIRCULAR_QUEUE_NAME']

  def next
    next_repo = @redis.lpop @queue_name
    @redis.rpush @queue_name, next_repo
    JSON.parse(next_repo)
  end
end
