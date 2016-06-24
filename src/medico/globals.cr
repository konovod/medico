require "./data/i18n/ru.cr"
require "math"

alias FLOAT = Float32


def f(value) : FLOAT
  return FLOAT.new(value)
end

def s(value)
  return $s[value]
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
#DEF_RND = Random::DEFAULT

def randg(norm, sigma, random = DEF_RND)
  u = random.rand
  v = random.rand
  x = Math.sqrt(-2*Math.log(u))*Math.cos(2*Math::PI*v)
  #x = -3 if x < -3
  #x = 3 if x > 3
  return x * sigma + norm
end

def weighted_sample(arr : Array(T), random = DEF_RND)
   weights = arr.map{|item| yield(item) }
   total = weights.sum
   point = random.rand * total
   arr.zip(weights).each do |n,w|
     return n if w >= point
     point -= w
   end
end

$verbose = false
def logs(s)
  puts s if $verbose
end

# TODO: def fill_hash
