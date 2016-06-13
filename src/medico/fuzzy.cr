alias FLOAT = Float32

def f(value) : FLOAT
  return FLOAT.new(value)
end



module Fuzzy
  extend self

  def triangular(zeroval, oneval, p1, random = Random::DEFAULT) : FLOAT
    p2 = FLOAT.new(random.rand)
    return (p2 - p1).abs * (zeroval - oneval) + oneval
  end

  abstract class FuzzySet
    abstract def sample(random = Random::DEFAULT)
    abstract def rate(value)

    def check(value, random = Random::DEFAULT)
      arate = rate(value)
      return false if arate == 0
      return true if arate == 1
      return random.rand < arate
    end

    def incremental(oldvalue, newvalue, oldstate, random = Random::DEFAULT)
      # sanity checks
      return oldstate if oldvalue == newvalue
      rate2 = rate(newvalue)
      return false if rate2 == 0
      return true if rate2 == 1
      rate1 = rate(oldvalue)
      return oldstate if rate1 == rate2
      # actual checks
      return oldstate if oldstate == (rate2 > rate1)
      if rate2 > rate1
        return rand < (rate2 - rate1) / (1 - rate1)
      else
        return rand < rate2 / rate1
      end
    end
  end

  class Trapezoid < FuzzySet
    property min : FLOAT
    property topmin : FLOAT
    property topmax : FLOAT
    property max : FLOAT

    def initialize(@topmin, @topmax, adelta)
      @min = 0
      @max = 0
      delta = adelta
    end

    def delta
      @topmin - @min
    end

    def delta=(delta)
      @min = @topmin - delta
      @max = @topmax + delta
    end

    def initialize(@min, @topmin, @topmax, @max)
    end

    def sample(random = Random::DEFAULT)
      range = {@topmax - @topmin, (@topmin - @min)/2, (@max - @topmax)/2}
      point = FLOAT.new(random.rand*range.sum)
      index = range.each_with_index do |w, i|
        break i if w >= point
        point -= w
      end
      case index
      when 0 # topmin ... topmax
        return @topmin + point
      when 1 # min ... topmin
        return Fuzzy.triangular(@min, @topmin, point/((@topmin - @min)/2), random)
      when 2 # topmax ... max
        return Fuzzy.triangular(@max, @topmax, point/((@max - @topmax)/2))
      else
        raise "sample failed for #{range}, (#{self})"
      end
    end

    def rate(value)
      return 0 if value <= @min
      return 0 if value >= @max
      return 1 if value >= @topmin && value <= @topmax
      return f(value - @min) / (@topmin - @min) if value < @topmin
      return f(@max - value) / (@max - @topmax)
    end
  end

  class Param
    getter min : FLOAT, max : FLOAT, average : FLOAT

    def initialize(@min, @average, @max)
    end
  end

  class ParamValue
    property real : FLOAT
    getter owner : Param

    def initialize(aowner, @real = aowner.average)
      @owner = aowner
    end
  end

  class RateSet < Array(FuzzySet)

    def estimate(value : ParamValue, oldvalue : (ParamValue | Nil) = nil, oldestimate : (FuzzySet | Nil) = nil) : (FuzzySet | Nil)
      rates = map { |x| {x, x.rate(value.real)} }.select { |(x, v)| v > 0 }
      case rates.size
      when 0
        raise "estimate failed for #{value} (#{self})"
      when 1
        return rates.first[0]
      else
        # TODO: incremental estimating
        rates.max_by { |(x, v)| v }.first
      end
    end
  end



end
