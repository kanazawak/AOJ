class UnionFind
  def initialize
    @obj_to_node = {}
  end

  def size(x)
    node = @obj_to_node[x]
    node ? node.root.size : 1
  end

  class UnionFind::Node
    def initialize(obj)
      @obj = obj
      @parent = self
      @size = 1
      @rank = 0
    end

    def root
      return self if @parent == self
      @parent = @parent.root
    end  

    attr_accessor :parent, :size, :rank
  end

  def unite(x, y)
    u = (@obj_to_node[x] ||= UnionFind::Node.new(x)).root
    v = (@obj_to_node[y] ||= UnionFind::Node.new(y)).root
    return if u == v
    if u.rank > v.rank
      v.parent = u
      u.size += v.size
    elsif v.rank > u.rank
      u.parent = v
      v.size += u.size
    else
      u.parent = v
      v.rank += 1
      v.size += u.size
    end
  end

  def same?(x, y)
    return false unless u = @obj_to_node[x]
    return false unless v = @obj_to_node[y]
    u.root == v.root
  end
end
