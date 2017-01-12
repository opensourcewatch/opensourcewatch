# A virtual model that lives in Redis
class RedisRepository
  include Comparable

  attr_reader :priority, :freq_popped, :priority_score

  def initialize(id, url, priority, freq_popped)
    @id, @url, @priority, @freq_popped = id, url, priority, freq_popped

    calculate_priority
  end

  def increment
    @freq_popped += 1
  end

  def calculate_priority
    # NOTE: If we just do this the values will continually decay toward 0
    @priority_score = @priority / (@freq_popped + 1.0)
  end

  def <=>(other)
    @priority_score <=> other.priority_score
  end

  def to_json
    {
      id: @id,
      url: @url,
      priority: @priority,
      priority_score: @priority_score,
      freq_popped: @freq_popped
    }.to_json
  end
end
