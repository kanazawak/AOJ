#!/usr/bin/env ruby

=begin
Verifier:
  AOJ 1171 Laser Beam Reflections:
    reflection, cross point
  AOJ 1283 Most Distant Point from the Sea:
    incircle, polygon-point containment
  AOJ 2173 Wind Passages:
    distance between line-segments
  AOJ 2827 Industrial Convex Pillar City:
    convex hull, distance between polygons, polygon-point containment
=end

PRECISION = 10

class Vector2D
  def initialize(*args)
    @x, @y = args
  end
  attr_reader :x, :y

  def -@
    Vector2D.new(-@x, -@y)
  end

  def -(v)
    Vector2D.new(@x - v.x, @y - v.y)
  end

  def +(v)
    Vector2D.new(@x + v.x, @y + v.y)
  end

  def *(c)
    if c.kind_of?(Numeric)
      Vector2D.new(@x * c, @y * c)
    else
      raise "unsupported class"
    end
  end

  def /(c)
    if c.kind_of?(Numeric)
      Vector2D.new(@x / c.to_f, @y / c.to_f)
    else
      raise "unsupported class"
    end
  end

  def inner_product(v)
    @x * v.x + @y * v.y
  end
  alias_method :dot, :inner_product

  def cross_product(v)
    @x * v.y - @y * v.x
  end
  alias_method :cross, :cross_product

  def norm
    Math.sqrt(@x * @x + @y * @y)
  end

  def normalize
    raise "zero vector cannot be normalized" if norm == 0
    self / norm
  end

  def to_a
    [@x, @y]
  end
end

class LineSegment
  def initialize(*args)
    if args.size == 2
      @point1, @point2 = args
    elsif args.size == 4
      @point1, @point2 = Vector2D.new(args[0], args[1]), Vector2D.new(args[2], args[3])
    else
      raise "unsupported number of arguments"
    end
  end
  attr_reader :point1, :point2

  def length
    (@point1 - @point2).norm
  end

  def perpendicular_vector(point)
    u = @point2 - @point1
    v = point - @point1
    u * (u.dot(v) / u.norm ** 2) - v
  end

  def projection(point)
    point + perpendicular_vector(point)
  end

  def reflection(point)
    point + perpendicular_vector(point) * 2
  end

  def parallel?(other)
    u = @point2 - @point1
    v = other.point2 - other.point1
    u.cross(v).round(PRECISION) == 0
  end

  def intersect?(other)
    v1 = @point2 - @point1
    v2 = other.point1 - @point1
    if parallel?(other)
      return false if v1.cross(v2).round(PRECISION) != 0
      return distance(other.point1).round(PRECISION) == 0 ||
             distance(other.point2).round(PRECISION) == 0 ||
             other.distance(@point1).round(PRECISION) == 0 ||
             other.distance(@point2).round(PRECISION) == 0
    end
    v3 = other.point2 - @point1
    v4 = other.point2 - other.point1
    v5 = @point1 - other.point1
    v6 = @point2 - other.point1
    return (v1.cross(v2) * v1.cross(v3)).round(PRECISION) < 0 &&
           (v4.cross(v5) * v4.cross(v6)).round(PRECISION) < 0
  end

  def cross_point(other)
    u = @point2 - @point1
    v = other.point2 - other.point1
    @point1 + u * v.cross(other.point1 - @point1) / v.cross(u).to_f
  end

  def distance(other)
    if other.class == Vector2D
      u = @point2 - @point1
      v = other - @point1
      ip = u.dot(v)
      return (other - @point1).norm if ip <= 0
      return (other - @point2).norm if ip >= u.norm ** 2
      return u.cross(v).abs / u.norm
    elsif other.class == LineSegment
      return 0 if intersect?(other)
      return [
        distance(other.point1),
        distance(other.point2),
        other.distance(@point1),
        other.distance(@point2)
      ].min
    else
      raise "unsupported class"
    end
  end
end

def incircle_center(l1, l2, l3)
  u, v, w = l1.cross_point(l2), l2.cross_point(l3), l3.cross_point(l1)
  a, b, c = (w - v).norm, (u - w).norm, (v - u).norm
  (u * a + v * b + w * c) / (a + b + c)
end

def convex_hull_path(points, type)
  raise "unknown type" if type != :upper && type != :lower
  groups = points.group_by {|point| point.x }
  selected = type == :upper ?
    groups.map {|x, g| g.max_by(&:y) } :
    groups.map {|x, g| g.min_by(&:y) }
  sorted = selected.sort_by(&:x)

  path = [sorted.shift]
  until sorted.empty?
    if path.size >= 2
      p1 = path[-2]
      p2 = path[-1]
      p3 = sorted[0]
      if ((p2 - p1).cross(p3 - p2) <=> 0) == (type == :upper ? 1 : -1)
        path.pop
        redo
      end
    end
    path << sorted.shift
  end
  path
end

class Polygon
  def initialize(points)
    @lines = (points + [points[0]]).each_cons(2).map do |p1, p2|
      LineSegment.new(p1, p2)
    end
  end
  attr_reader :lines

  def distance(other)
    if other.class == Vector2D || other.class == LineSegment
      return @lines.map {|l| l.distance(other) }.min
    elsif other.class == Polygon
      ret = other.lines.map {|l| distance(l) }.min
    else
      raise "unsupported class"
    end
  end

  def contain?(point)
    signs = []
    lines.each do |l|
      cps = (l.point2 - l.point1).cross(point - l.point1).round(PRECISION)
      sign = (cps <=> 0)
      signs << sign if sign != 0
    end
    signs.uniq.size <= 1
  end
end
