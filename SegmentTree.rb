class SegmentTreeBase
  def initialize(arr, l = 0, r = arr.size - 1)
    @l, @r = l, r
    if @l == @r
      @agg = arr[l]
    else
      c = (l + r) / 2
      @left_child = self.class.new(arr, l, c)
      @right_child = self.class.new(arr, c + 1, r)
      @agg = aggregation_of(@left_child.agg, @right_child.agg)
    end
  end

  attr_reader :agg, :l, :r

  def update(i, x)
    if @l == @r
      single_update(x)
    else
      (i <= @left_child.r ? @left_child : @right_child).update(i, x)
      @agg = aggregation_of(@left_child.agg, @right_child.agg)
    end
  end

  def query(l, r)
    return @agg if l == @l && r == @r
    return @left_child.query(l, r) if r <= @left_child.r
    return @right_child.query(l, r) if @right_child.l <= l
    agg_left = @left_child.query(l, @left_child.r)
    agg_right = @right_child.query(@right_child.l, r)
    return aggregation_of(agg_left, agg_right)
  end
end

class SegmentTree < SegmentTreeBase
  def single_update(x)
    # @agg = x
    # @agg += x
  end

  def aggregation_of(x, y)
    # [x, y].min
    # x + y
  end
end

class LazySegmentTreeBase
  def initialize(arr, l = 0, r = arr.size - 1)
    @l, @r = l, r
    @lazy = nil
    if l == r
      @agg = arr[l]
    else
      c = (l + r) / 2
      @left_child = self.class.new(arr, l, c)
      @right_child = self.class.new(arr, c + 1, r)
      @agg = aggregation_of(@left_child.agg, @right_child.agg)
    end
  end

  attr_reader :agg, :l, :r

  def update(l, r, x)
    if l == @l && r == @r
      defer(x)
    else
      force
      if r <= @left_child.r
        @left_child.update(l, r, x)
      elsif @right_child.l <= l
        @right_child.update(l, r, x)
      else
        @left_child.update(l, @left_child.r, x)
        @right_child.update(@right_child.l, r, x)
      end
      @left_child.force
      @right_child.force
      @agg = aggregation_of(@left_child.agg, @right_child.agg)
    end
  end

  def force
    return if !@lazy
    x = @lazy
    @lazy = nil
    whole_update(x)
    @left_child.update(@left_child.l, @left_child.r, x) if @left_child
    @right_child.update(@right_child.l, @right_child.r, x) if @right_child
  end

  def query(l, r)
    force
    return @agg if l == @l && r == @r
    if r <= @left_child.r
      return @left_child.query(l, r)
    elsif @right_child.l <= l
      return @right_child.query(l, r)
    else
      agg_left = @left_child.query(l, @left_child.r)
      agg_right = @right_child.query(@right_child.l, r)
      return aggregation_of(agg_left, agg_right)
    end
  end
end

class LazySegmentTree < LazySegmentTreeBase
  def initialize(arr, l = 0, r = arr.size - 1)
    # @n = r - l + 1
    super(arr, l, r)
  end

  def defer(x)
    # @lazy = x
  end

  def whole_update(x)
    # @agg = x * @n
  end

  def aggregation_of(x, y)
    # x + y
  end
end
