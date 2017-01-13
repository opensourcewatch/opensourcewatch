require_relative "redis_wrapper"

class RedisQueue
  def initialize(repos = nil, queue_name = nil)
    @redis = RedisWrapper.new.redis
    @queue_name = queue_name || ENV['REDIS_CIRCULAR_QUEUE_NAME']
    @repos = repos # Only needed for enqueing
  end

  def enqueue_redis
    # Insert into redis. The left side of the queue is the high side
    @redis.pipelined do
      @repos.each do |repo|
        # Must be a string
        member = {
          name: repo.name,
          id: repo.id,
          url: repo.url,
        }.to_json

        # Use the priority value as the initial score
        add(member)
      end
      puts "#{@repos.count} repos enqueued."
    end
  end

  def next
    next_repo = @redis.lpop @queue_name
    JSON.parse(next_repo)
  end

  private

  def add(member)
    @redis.rpush @queue_name, member
  end
end
