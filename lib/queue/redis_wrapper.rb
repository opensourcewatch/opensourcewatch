# Requires a redis connection to a valid redis server.
class RedisWrapper

  REDIS_ACTIVE_QUEUE_NAME   = 'repositories'
  REDIS_PRIORITY_QUEUE_NAME = 'prioritized_repositories'
  REDIS_BLANK_QUEUE_NAME    = 'blank_repositories'

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

  # TODO: refactor to a naive redis queue object
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

  # TODO: Modify to enqueue as a sorted set
  def redis_priority_requeue(queue_name: REDIS_PRIORITY_QUEUE_NAME, query: "stars > 10000", rescore: false)
    puts "Clearing priority queue..."
    redis.del queue_name

    tracked_repos = Repository.where(query)
    puts "Retrieved #{tracked_repos.count} repositories"

    calculate_scores(tracked_repos) if rescore

    tracked_repos = tracked_repos.order(:score)

    puts "Creating priority queue..."
    priority_queue = PriorityQueue.new(redis, queue_name, tracked_repos)
    priority_queue.enqueue
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

  def calculate_scores
    count = 0
    tracked_repos.in_batches do |batch|
      batch.each do |repo|
        repo.update_score
        count += 1
        puts "#{count} repos scored"
      end
    end
  end

  # TODO: refactor to just pop and push using ZREM and the sorted set
  def next_priority_repo
    queue_name = REDIS_PRIORITY_QUEUE_NAME
    queue = PriorityQueue.new(redis, queue_name)

    next_repo = queue.next
  end

  # TODO: refactor to use a looping queue object
  def next_active_repo
    next_data = redis.lpop(REDIS_ACTIVE_QUEUE_NAME)
    redis.rpush(REDIS_ACTIVE_QUEUE_NAME, next_data)
    JSON.parse(next_data)
  end

  # TODO: refactor to use a one-shot queue object
  def next_blank_repo
    next_data = redis.lpop(REDIS_BLANK_QUEUE_NAME)
    JSON.parse(next_data)
  end
end
