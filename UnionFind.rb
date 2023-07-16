require 'set'

class UnionFind
  def initialize
    @item_to_node = {}
    @root_nodes = Set.new
  end

  class Node
    def initialize(item)
      @item = item
      @parent = self
      @size = 1
      @rank = 0
    end

    def root
      return self if @parent == self
      @parent = @parent.root
    end

    attr_accessor :parent, :size, :rank, :item
  end
  @@Node = Node

  def add(item)
    if !@item_to_node[item]
      v = @@Node.new(item)
      @item_to_node[item] = v
      @root_nodes << v
    end
  end

  def include?(item)
    !!@item_to_node[item]
  end

  def size(x = nil)
    return @item_to_node.size if x == nil
    v = @item_to_node[x]
    if v
      return @item_to_node[x].root.size
    else
      return 1
    end
  end

  def union(x, y)
    add(x) if !@item_to_node[x]
    add(y) if !@item_to_node[y]
    u = @item_to_node[x].root
    v = @item_to_node[y].root
    return if u == v
    if u.rank > v.rank
      _link(u, v)
      u.size += v.size
      @root_nodes.delete(v)
    elsif v.rank > u.rank
      _link(v, u)
      v.size += u.size
      @root_nodes.delete(u)
    else
      _link(v, u)
      v.rank += 1
      v.size += u.size
      @root_nodes.delete(u)
    end
  end

  def same_component?(x, y)
    return false unless u = @item_to_node[x]
    return false unless v = @item_to_node[y]
    u.root == v.root
  end

  def components
    @item_to_node.keys.group_by {|x| @item_to_node[x].root}.values
  end

  def number_of_components
    @root_nodes.size
  end

  def root_items
    @root_nodes.map {|v| v.item }
  end

private
  def _link(parent, child)
    child.parent = parent
  end
end

class UndoableUnionFind < UnionFind
  def initialize
    super
    @history = []
  end

  class Node < UnionFind::Node
    def root
      return self if @parent == self
      @parent.root
    end
  end
  @@Node = Node

  def undo
    parent, child, were_same_rank = @history.pop
    child.parent = child
    parent.size -= child.size
    parent.rank -= 1 if were_same_rank
    @root_nodes << child
  end

private
  def _link(parent, child)
    child.parent = parent
    @history << [parent, child, parent.rank == child.rank]
  end
end
