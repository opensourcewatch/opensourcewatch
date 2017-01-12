# A virtual model that lives in Redis
class RedisRepository
  include Comparable

  attr_accessor :priority, :name
  attr_reader :value, :times_popped

  def initialize(id, name, value)
    @id, @name, @value = id, name, value

    @freq_popped = 0

    recalculate_priority
  end

  def increment
    @freq_popped += 1
  end

  def recalculate_priority
    # NOTE: If we just do this the values will continually decay toward 0
    @priority_score = @value / (@times_popped + 1.0)
  end

  def <=>(other)
    @priority_score <=> other.priority_score
  end
end
