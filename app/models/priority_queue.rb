# Virtual model to manage the prioritized redis queue
class PriorityQueue
  attr_reader :elements

  def initialize
    @elements = [nil]
  end

  def <<(element)
    element.calculate_priority
    @elements << element
    bubble_up(@elements.size - 1)
  end

  def bubble_up(index)
    parent_index = (index/2)

    return if index <= 1

    return if @elements[parent_index] >= @elements[index]

    exchange(index, parent_index)

    bubble_up(parent_index)
  end

  def exchange(source, target)
    @elements[source], @elements[target] = @elements[target], @elements[source]
  end

  def pop
    exchange(1, @elements.size - 1)

    max = @elements.pop
    max.increment # recalls how many times it was popped, decreases its index

    bubble_down(1)
    max
  end

  def pop_and_push
    ele = pop
    self.<<(ele)
    ele
  end

  def bubble_down(index)
    child_index = (index * 2)

    return if child_index > @elements.size - 1

    not_the_last_element = child_index < @elements.size - 1
    left_element = @elements[child_index]
    right_element = @elements[child_index + 1]
    child_index += 1 if not_the_last_element && right_element > left_element

    return if @elements[index] >= @elements[child_index]

    exchange(index, child_index)

    bubble_down(child_index)
  end

  def analyze
    # Pop X times
    iterations = 2 * elements.length
    iterations.times do
      self.pop_and_push
    end

    # Get all but the root element
    elements = self.elements[1..-1]

    priority_freq_pairs = elements.map do |ele|
      [ele.priority, ele.freq_popped]
    end

    # Create a hash to track total freq per prirority
    priority_freq_totals = {}
    (1..10).map do |key|
      key = key
      priority_freq_totals[key] = 0
    end

    # Sum the number of pops for each value
    # This is the number of times each bucket is hit
    priority_freq_pairs.each do |pair|
      key = pair[0]
      freq = pair[1]
      priority_freq_totals[key] += freq
    end

    percentages_hash = {}
    priority_freq_totals.each do |key, val|
      percentages_hash[key] = (val / iterations.to_f * 100).round(2)
    end

    p percentages_hash
  end
end
