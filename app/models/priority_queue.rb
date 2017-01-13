# TODO: refactor to be a sorted set wrapper
# Virtual model to manage the prioritized redis queue
class PriorityQueue
  PRIORITY_RANGE = (1..10).to_a

  def initialize(redis, queue_name, repos = nil)
    @redis = redis
    @queue_name = queue_name
    @repos = repos # Only needed for enqueing
  end

  def enqueue
    num_repos = @repos.count
    bucket_size = (num_repos.to_f / PRIORITY_RANGE.length).ceil

    # Insert into redis. The left side of the queue is the high side
    @redis.pipelined do
      index = 0
      # NOTE: If we were using rails 5 we could us in_batches.with_index
      @repos.in_batches(of: bucket_size) do |batch|
        priority = PRIORITY_RANGE.length - PRIORITY_RANGE[index]
        index += 1
        batch.each do |repo|
          # Must be a string
          member = {
            id: repo.id,
            url: repo.url,
            priority: priority,
          }.to_json

          # Use the priority value as the initial score
          add(member, priority)
        end
        puts "#{bucket_size} repos prioritized and enqueued."
      end
    end
  end

  def next
    # Redis sorts by the lowest score by default
    member = @redis.zrangebyscore("prioritized_repositories", "-inf", "+inf", withscores: true).first
    update_score(member)
    data = JSON.parse(member[0]) # The scraper needs the id
  end

  private

  def add(member, score)
    @redis.zadd @queue_name, score, member
  end

  def update_score(member)
    repo_data = JSON.parse(member[0])
    score = member[1]
    times_popped = score / repo_data['priority']

    increment = repo_data['priority'] * ( times_popped + 1 ) - score

    @redis.zincrby("prioritized_repositories", increment, member[0])
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
