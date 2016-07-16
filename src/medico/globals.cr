require "./data/i18n/ru.cr"
require "math"
require "./grammar"

alias FLOAT = Float32

def f(value) : FLOAT
  return FLOAT.new(value)
end

def s(value, t = Grammar::Noun)
  return t.new(parse: I18N[value])
end

class TEST_RND
  include Random

  def next_u32
    raise "RANDOM NOT PASSED"
  end

  def initialize
  end
end

DEF_RND = TEST_RND.new

# DEF_RND = Random::DEFAULT

def randg(norm, sigma, random = DEF_RND)
  u = random.rand
  v = random.rand
  x = Math.sqrt(-2*Math.log(u))*Math.cos(2*Math::PI*v)
  # x = -3 if x < -3
  # x = 3 if x > 3
  return x * sigma + norm
end

module Enumerable(T)
  def weighted_sample(random = DEF_RND)
    weights = map { |item| yield(item) }
    weighted_sample(weights, random)
  end

  private def zip(other)
    each_with_index do |elem, i|
      yield elem, other[i]
    end
  end

  private def zip(other : Array(U))
    pairs = Array({T, U}).new(size)
    zip(other) { |x, y| pairs << {x, y} }
    pairs
  end

  # TODO - iterator support?
  def weighted_sample(weights : (Array | Tuple), random = DEF_RND) : T
    total = weights.sum
    point = random.rand * total
    zip(weights) do |n, w|
      return n if w >= point
      point -= w
    end
    return first # to prevent "nillable" complain
  end

  def sorted_by? : Bool
    return true if empty?
    prev_value = yield(first)
    first = true
    each do |item|
      if first
        first = false
        next
      end
      value = yield(item)
      return false if value < prev_value
      prev_value = value
    end
    return true
  end

  def sorted?
    sorted_by? { |it| it }
  end
end

# TODO - replace with universal function? how to yield in recursive implementation?
# TODO - repeatable, sorted combinations, use std product?
def each_combination(n : Int32, aset : Enumerable(T))
  case n
  when 1
    aset.each do |e1|
      yield({e1})
    end
  when 2
    aset.each do |e1|
      aset.each do |e2|
        yield({e1, e2}) if e1 != e2
      end
    end
  when 3
    aset.each do |e1|
      aset.each do |e2|
        next if e1 == e2
        aset.each do |e3|
          next if e1 == e3 || e2 == e3
          yield({e1, e2, e3})
        end
      end
    end
  when 4
    aset.each do |e1|
      aset.each do |e2|
        next if e1 == e2
        aset.each do |e3|
          next if e1 == e3 || e2 == e3
          aset.each do |e4|
            next if e1 == e4 || e2 == e4 || e3 == e4
            yield({e1, e2, e3, e4})
          end
        end
      end
    end
  else
    raise "each_combination not implemented for #{n}"
  end
end

# TODO: replace to std logger
$verbose = false

def logs(s)
  puts s if $verbose
end

# TODO: def fill_hash

def stat_to_int(value, random = DEF_RND)
  result = value.to_i
  result += 1 if value != result && random.rand < value - result
  result
end
