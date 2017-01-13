# TODO: refactor to divide into 10 queues
# Virtual model to manage the prioritized redis queue
class CircularRedisQueue

  def initialize(redis, queue_name, repos = nil)
    @redis = redis
    @queue_name = queue_name
    @repos = repos # Only needed for enqueing
  end

  def enqueue
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
    @redis.rpush @queue_name, next_repo
    JSON.parse(next_repo)
  end

  private

  def add(member)
    @redis.rpush @queue_name, member
  end
end




# # Push and pop
# all_repos = redis.lrange(queue_name, 0, -1)
# all_repos.each do |repo_data|
#   parsed_data = JSON.parse(repo_data)
#
#   repo = RedisRepository.new(
#     parsed_data["id"],
#     parsed_data["url"],
#     parsed_data["priority"],
#     parsed_data["freq_popped"]
#   )
#
#   in_memory_queue << repo
# end
#
# next_repo = JSON.parse(in_memory_queue.pop_and_push.to_json)
#
# # Save new queue to redis
# redis.del queue_name
# in_memory_queue.elements[1..-1].each do |ele|
#   redis.lpush queue_name, ele.to_json
# end
