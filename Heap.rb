class Heap
  def initialize
    @array = []
    @index = {}
  end

  def add(item, key)
    @array << [item, key]
    @index[item] = @array.size - 1
    _lift_up(@array.size - 1)
  end

  def del_opt
    raise "heap is empty!" if empty?
    opt = @array[0]
    if size > 1
      _swap(0, @array.size - 1)
      @array.pop
      _lift_down(0)
    else
      @array.pop
    end
    @index.delete(opt[0])
    return { item: opt[0], key: opt[1] }
  end

  def update_key(item, new_key)
    i = @index[item]
    return unless i
    old_key = @array[i][1]
    @array[i][1] = new_key
    if compare(new_key, old_key) < 0
      _lift_up(i)
    else
      _lift_down(i)
    end
  end

  def opt_item
    @array[0][0]
  end

  def opt_key
    @array[0][1]
  end

  def key(item)
    i = @index[item]
    i ?  @array[i][1] : nil
  end

  def items
    @array.map(&:last)
  end

  def delete(item)
    if include?(item)
      update_key(item, dummy_key)
      del_opt
    end
  end

  def include?(item)
    !!@index[item]
  end

  def size
    @array.size
  end

  def empty?
    @array.empty?
  end

  ######################################
  private
  ######################################

  def _swap(i, j)
    u = @array[i]
    v = @array[j]
    @index[u[0]], @index[v[0]] = j, i
    @array[i], @array[j] = v, u
  end

  def _lift_up(i)
    return if i == 0
    j = (i - 1) / 2
    if compare(@array[i][1], @array[j][1]) < 0
      _swap(i, j)
      _lift_up(j)
    end
  end

  def _lift_down(i)
    j = 2 * i + 1
    k = j + 1
    if k >= size
      return if j >= size
      if compare(@array[i][1], @array[j][1]) > 0
        _swap(i, j)
        _lift_down(j)
      end
    else
      l = (compare(@array[j][1], @array[k][1]) < 0 ? j : k)
      if compare(@array[i][1], @array[l][1]) > 0
        _swap(i, l)
        _lift_down(l)
      end
    end
  end
end

class MinHeap < Heap
  def dummy_key
    -Float::INFINITY
  end
  def compare(x, y)
    x <=> y
  end
end

class MaxHeap < Heap
  def dummy_key
    Float::INFINITY
  end
  def compare(x, y)
    y <=> x
  end
end
