require "./globals"

module Fuzzy
  extend self

  def triangular(zeroval, oneval, p1, random = DEF_RND) : FLOAT
    p2 = FLOAT.new(random.rand)
    return (p2 - p1).abs * (zeroval - oneval) + oneval
  end

  abstract class FuzzySet
    abstract def sample(random = DEF_RND)
    abstract def rate(value : FLOAT)
    abstract def average : FLOAT

    def check(value, random = DEF_RND)
      arate = rate(value)
      return false if arate == 0
      return true if arate == 1
      return random.rand < arate
    end

    def incremental(oldvalue, newvalue, oldstate, random = DEF_RND)
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

  class Pike < FuzzySet
    property value : FLOAT

    def initialize(@value)
    end

    def sample(random = DEF_RND)
      return @value
    end

    def rate(value)
      return 0 # TODO: think about it
    end

    def average
      return @value
    end

    def to_s(io)
      io << "(#{@value})"
    end
  end

  class Trapezoid < FuzzySet
    property min : FLOAT
    property topmin : FLOAT
    property topmax : FLOAT
    property max : FLOAT

    def to_s(io)
      io << "[#{@min}-#{@topmin}-#{@topmax}-#{@max}]"
    end

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

    def average
      # return @topmin
      # simple algorithm
      if @topmin - @min == @max - @topmax
        return (@topmin + @topmax)/2
      else
        # patented algorithm (c)(tm)(ltd)
        a = @topmax - @topmin
        b = @max - @min
        c = @topmin - @min
        return (2*a*c + a*a + c*b + a*b + b*b)/3/(a + b) + @min
      end
    end

    def initialize(@min, @topmin, @topmax, @max)
    end

    def sample(random = DEF_RND)
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
        return Fuzzy.triangular(@max, @topmax, point/((@max - @topmax)/2), random)
      else
        raise "sample failed for #{range}, (#{self})"
      end
    end

    def rate(value)
      return 1 if value >= @topmin && value <= @topmax
      return 0 if value <= @min
      return 0 if value >= @max
      return f(value - @min) / (@topmin - @min) if value < @topmin
      return f(@max - value) / (@max - @topmax)
    end
  end

  def trap_or_pike(min, average, max)
    if min == max
      Pike.new(min)
    else
      Trapezoid.new(min, average, max)
    end
  end

  def trap_or_pike(min, topmin, topmax, max)
    if min == max
      Pike.new(f(min))
    else
      Trapezoid.new(min, topmin, topmax, max)
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

    def estimate(how : RateSet)
      how.estimate(self)
    end
  end

  class RateSet
    getter items
    getter names

    def initialize()
      @items = Array(FuzzySet).new
      @names = Array(Symbol).new
    end

    def initialize(param : Param, additional = 0)
      initialize()
      generate_for(param, additional)
    end

    def dump
      p @items.map(&.to_s)
    end

    def estimate(value : ParamValue,
                 oldvalue : (ParamValue | Nil) = nil,
                 oldestimate : (Int32|Symbol| Nil) = nil) : (Int32|Symbol)
      estimate_f(value.real, oldvalue ? oldvalue.real : nil, oldestimate)
    end

    def estimate_f(value : FLOAT,
                 oldvalue : (FLOAT | Nil) = nil,
                 oldestimate : (Int32 | Symbol | Nil) = nil) : (Int32|Symbol)
      rates = items.zip((0...items.size).to_a).map do |(x, i)|
        {i, x.rate(value)}
      end.select { |(i, v)| v > 0 }
      index = case rates.size
      when 0
        dump
        raise "estimate failed for #{value} (#{self})"
      when 1
        return rates.first.first
      else
        # TODO: incremental estimating
        rates.max_by { |(i, v)| v }.first
      end
      if index < @names.size
        return @names[index]
      else
        return index
      end
    end

    private def fill_open_range(min, max, count)
      return if count <= 0
      pos = min
      delta = (max - min)/(count + 1)
      count.times do |i|
        @items << Fuzzy.trap_or_pike(pos, pos + delta, pos + delta, pos + 2*delta)
        pos += delta
      end
    end

    def generate_for(min, average, max, additional = 0)
      @items.clear

      @items << Fuzzy.trap_or_pike(min, min, min, average)
      fill_open_range(min, average, additional)
      @items << Fuzzy.trap_or_pike(min, average, average, max)
      fill_open_range(average, max, additional)
      @items << Fuzzy.trap_or_pike(average, max, max, max)
    end

    def fill_names(anames = [] of Symbol)
      @names.clear

      @items.size.times do |i|
        @names << i < anames.size ? anames[i] : :Unknown
      end
    end

    def initialize(*, fixed)
      initialize()
      fixed.each do |item|
        @names << item[:name]
        width = item[:max] - item[:min]
        @items << Fuzzy.trap_or_pike(item[:min] - width, item[:min], item[:max], item[:max] + width)
      end
    end

    def generate_for(param : Param, additional = 0)
      generate_for(param.min, param.average, param.max, additional)
    end
  end
end
