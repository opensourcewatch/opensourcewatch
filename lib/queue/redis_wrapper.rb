# Requires a redis connection to a valid redis server.
class RedisWrapper

  REDIS_ACTIVE_QUEUE_NAME   = 'repositories'
  REDIS_PRIORITY_QUEUE_NAME = 'prioritized_repositories'
  REDIS_BLANK_QUEUE_NAME    = 'blank_repositories'

  PRIORITY_RANGE = (1..10).to_a

  attr_reader :redis

  def initialize
    redis
  end

  def queue_length(queue_name)
    redis.llen(queue_name).to_i
  end

  def next_repo(queue_name)
    if queue_name == REDIS_PRIORITY_QUEUE_NAME
      next_priority_repo
    elsif queue_name == REDIS_ACTIVE_QUEUE_NAME
      next_active_repo
    elsif queue_name == REDIS_BLANK_QUEUE_NAME
      next_blank_repo
    else
      raise "Next repo is being requested for unrecognized redis queue."
    end
  end

  def redis_requeue(queue_name: REDIS_ACTIVE_QUEUE_NAME, query: "stars > 10")
    redis.del queue_name

    start_time = Time.now
    count = 0
    redis.pipelined do
      Repository.where(query).in_batches do |batch|
        puts "Enqueuing #{queue_name}"
        batch.each do |repo|
          redis.rpush queue_name,{
            id: repo.id,
            url: repo.url
          }.to_json
        end
        count += 1000
        puts "#{count} repos enqueued"
      end
    end
    puts "#{redis.llen queue_name} were enqueued in #{((Time.now - start_time) / 60).round(2)} mins"
  end

  def redis_priority_requeue(queue_name: REDIS_PRIORITY_QUEUE_NAME, query: "stars > 10000", rescore: false)
    puts "Clearing priority queue..."
    redis.del queue_name

    tracked_repos = Repository.where(query)
    num_repos = tracked_repos.count
    puts "Retrieved #{num_repos} repositories"

    # Calculate scores for repo pool
    if rescore
      count = 0
      tracked_repos.in_batches do |batch|
        batch.each do |repo|
          repo.update_score
          count += 1
          puts "#{count} repos scored"
        end
      end
    end

    # Order them by score divide into X parts
    tracked_repos = tracked_repos.order(:score)
    bucket_size = (num_repos.to_f / PRIORITY_RANGE.length).ceil

    # Assign priority to every redis hash
    # Pushes the lowest priority up to the highest
    # The left side of the queue is the high side
    redis.pipelined do
      index = 0
      # NOTE: If we were using rails 5 we could us in_batches.with_index
      tracked_repos.in_batches(of: bucket_size) do |batch|
        priority = PRIORITY_RANGE[index]
        index += 1

        batch.each do |repo|
          redis.lpush queue_name, {
            id: repo.id,
            url: repo.url,
            priority: priority,
            priority_score: 10.0,
            freq_popped: 0
          }.to_json
        end
        puts "#{bucket_size} repos prioritized and enqueued."
      end
    end
  end

  private

  def redis
    ip = ENV['REDIS_SERVER_IP']
    pw = ENV['REDIS_SERVER_PW']

    @redis ||= Redis.new(
      host: ip,
      password: pw
    )
  end

  # TODO: pulling redis into memory is inefficient and won't work with
  # multiple scrapers
  def next_priority_repo
    queue_name = REDIS_PRIORITY_QUEUE_NAME
    in_memory_queue = PriorityQueue.new

    all_repos = redis.lrange(queue_name, 0, -1)
    all_repos.each do |repo_data|
      parsed_data = JSON.parse(repo_data)

      repo = RedisRepository.new(
        parsed_data["id"],
        parsed_data["url"],
        parsed_data["priority"],
        parsed_data["freq_popped"]
      )

      in_memory_queue << repo
    end

    next_repo = JSON.parse(in_memory_queue.pop_and_push.to_json)

    # Save new queue to redis
    redis.del queue_name
    in_memory_queue.elements[1..-1].each do |ele|
      redis.lpush queue_name, ele.to_json
    end

    next_repo
  end

  def next_active_repo
    next_data = redis.lpop(REDIS_ACTIVE_QUEUE_NAME)
    redis.rpush(REDIS_ACTIVE_QUEUE_NAME, next_data)
    JSON.parse(next_data)
  end

  def next_blank_repo
    next_data = redis.lpop(REDIS_BLANK_QUEUE_NAME)
    JSON.parse(next_data)
  end
end
