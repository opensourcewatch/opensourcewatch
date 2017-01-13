# The priority queue is a queue of queues
class PriorityQueue
  PRIORITY_RANGE = (1..10).to_a

  def initialize
    @unique_queues = generate_queues

    # add them to a skewed distribution list
      # n! elements in queue
    @queues = skewed_dist_of_queues(@unique_queues)
  end

  def next
    # get leftmost queue and push to the end
    queue = @queues.shift
    @queues.push(queue)
    # return the next repository
    queue.next
  end

  private

  def generate_queues
    priority_tags = PRIORITY_RANGE
    base_queue_name = ENV['REDIS_PRIORITY_QUEUE_BASE_NAME']

    unique_queues = []
    priority_tags.each do |tag|
      queue_name = base_queue_name + '_' + tag.to_s
      unique_queues << CircularRedisQueue.new(queue_name)
    end
    unique_queues
  end

  def skewed_dist_of_queues(queues)
    # Want to create a distribution like:
    #   [3, 2, 1] + [3, 2] + [3]
    skewed_dist_of_queues = []
    while queues.length > 0
      queues.each do |queue|
        skewed_dist_of_queues << queue
      end
      queues.pop
    end
    skewed_dist_of_queues
  end
end
