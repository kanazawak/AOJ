#!/usr/bin/env ruby
/*
Verifier:
  AOJ CGL
  AOJ 1171 Laser Beam Reflections:
    reflection, cross point
  AOJ 1283 Most Distant Point from the Sea:
    incircle, polygon-point containment
  AOJ 2173 Wind Passages:
    distance between line-segment
*/

PRECISION = 10

class Vector2D
  def initialize(*args)
    @x, @y = args
  end
  attr_reader :x, :y

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
    t = u * (u.dot(v) / u.norm ** 2)
    t - v
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
      return perpendicular_vector(other).norm
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

  def intersect?(other)
    if parallel?(other)
      return distance(other.point1).round(PRECISION) == 0 ||
             distance(other.point2).round(PRECISION) == 0 ||
             other.distance(@point1).round(PRECISION) == 0 ||
             other.distance(@point2).round(PRECISION) == 0
    end
    distance(cross_point(other)).round(PRECISION) == 0
  end
end

def incircle_center(l1, l2, l3)
  u, v, w = l1.cross_point(l2), l2.cross_point(l3), l3.cross_point(l1)
  a, b, c = (w - v).norm, (u - w).norm, (v - u).norm
  (u * a + v * b + w * c) / (a + b + c)
end
