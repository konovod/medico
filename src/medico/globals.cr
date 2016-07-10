require "./data/i18n/ru.cr"
require "math"
require "./grammar"

alias FLOAT = Float32

def f(value) : FLOAT
  return FLOAT.new(value)
end

def s(value, t = Grammar::Noun)
  return t.new(parse: $s[value])
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

# TODO: monkey patching all the way
def weighted_sample(arr : Enumerable(T), random = DEF_RND)
  weights = arr.map { |item| yield(item) }
  weighted_sample(arr, weights, random)
end

def weighted_sample(arr : Enumerable(T), weights : Enumerable(Y), random = DEF_RND) : T
  total = weights.sum
  point = random.rand * total
  arr.zip(weights).each do |n, w|
    return n if w >= point
    point -= w
  end
  return arr.first
end

def sorted_by?(coll : Enumerable(T)) : Bool
  return true if coll.empty?
  prev_value = yield(coll.first)
  first = true
  coll.each do |item|
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

def sorted?(coll : Enumerable(T))
  sorted_by?(coll) { |it| it }
end


#TODO - replace with universal function? how to yield in recursive implementation?
#TODO - repeatable, sorted combinations, use std product?
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
    raise "each_combination not implementated for #{n}"
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
