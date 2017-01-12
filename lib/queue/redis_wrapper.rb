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
    if queue_name == REDIS_ACTIVE_QUEUE_NAME
      self.next_active_repo
    elsif queue_name == REDIS_BLANK_QUEUE_NAME
      self.next_blank_repo
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

  def redis_priority_requeue(queue_name: REDIS_PRIORITY_QUEUE_NAME, query: "stars > 10")
    redis.del queue_name

    tracked_repos = Repository.where(query)
    num_repos = tracked_repos.count
    puts "Retrieved #{num_repos} repositories"

    # calculate scores for repo pool
    count = 0
    tracked_repos.in_batches do |batch|
      batch.each do |repo|
        repo.update_score
        count += 1
        puts "#{count} repos scored"
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
            priority: priority
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

  def next_active_repo
    next_data = redis.lpop(REDIS_ACTIVE_QUEUE_NAME)
    redis.rpush(REDIS_ACTIVE_QUEUE_NAME, next_data)
    next_data
  end

  def next_blank_repo
    redis.lpop(REDIS_BLANK_QUEUE_NAME)
  end
end
