# TODO: convert to use redis
class RelativePriorityQueue
  attr_reader :elements

  def initialize
    @elements = [nil]
  end

  def <<(element)
    element.recalculate_priority
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
end
