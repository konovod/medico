require "spec"
require "../src/medico/fuzzy.cr"

include Fuzzy

$r = Random.new(1)

def histogram(&block : -> FLOAT)
  hist = Array(Int32).new(10, 0)
  10000.times do
    x = yield
    raise "incorrect value #{x}" if x < 0 || x > 1
    hist[Int32.new(x*10)] += 1
  end
  # p hist
  hist
end

describe Fuzzy do
  it "triangular" do
    res = histogram do
      triangular(0, 100, $r.rand, $r) / 100
    end
    (res[0] + res[1] + res[2] < res[9]).should eq(true)
  end

  it "triangular2" do
    res = histogram do
      triangular(100, 60, $r.rand, $r) / 100
    end
    (res[8] + res[9] < res[6]).should eq(true)
  end

  a = Trapezoid.new(f(0), f(50), f(60), f(100))

  it "sampling" do
    res = histogram do
      a.sample($r) / 100
    end
    (res[5] + res[6]).should be_close(3333, 500)
  end

  it "check absolute" do
    a.check(50).should eq(true)
    a.check(60).should eq(true)
    a.check(0).should eq(false)
    a.check(100).should eq(false)

    10000.times.map { |x| a.check(25, $r) ? 1 : 0 }.sum.should be_close(5000, 200)
    10000.times.map { |x| a.check(95, $r) ? 1 : 0 }.sum.should be_close(10000/8, 200)
  end
end

def rate_value(trapezoid, start, finish, n, steps)
  rate = f(0)
  n.times do
    v = f(start)
    inside = trapezoid.check(v, $r)
    steps.times do
      vnew = v + f(finish - start) / steps
      inside = trapezoid.incremental(v, vnew, inside, $r)
      v = vnew
    end
    rate += 1 if inside
    rate -= 1 if trapezoid.check(finish, $r)
  end
  1.0*rate / n
end

describe Fuzzy do
  a = Trapezoid.new(f(0), f(50), f(60), f(100))

  delta = 0.1
  it "check relative" do
    rate_value(a, 0, 25, 1000, 21).should be_close(0, delta)
    rate_value(a, 0, 80, 1000, 2).should be_close(0, delta)
    rate_value(a, 0, 80, 1000, 101).should be_close(0, delta)
    rate_value(a, 40, 25, 1000, 10).should be_close(0, delta)
    rate_value(a, 80, 25, 1000, 21).should be_close(0, delta)
    rate_value(a, 150, 80, 1000, 11).should be_close(0, delta)

    rate_value(a, 0, 100, 1000, 10).should be_close(0, delta)
    rate_value(a, 0, 55, 1000, 10).should be_close(0, delta)
    rate_value(a, 0, 60, 1000, 10).should be_close(0, delta)
    rate_value(a, 20, 0, 1000, 10).should be_close(0, delta)
    rate_value(a, 20, 100, 1000, 10).should be_close(0, delta)
  end

  a = Trapezoid.new(f(0), f(0), f(60), f(100))
  it "check relative2" do
    rate_value(a, 0, 80, 1000, 2).should be_close(0, delta)
    rate_value(a, 40, 25, 1000, 10).should be_close(0, delta)
    rate_value(a, 80, 25, 1000, 21).should be_close(0, delta)
    rate_value(a, 150, 80, 1000, 11).should be_close(0, delta)
  end

  a = Trapezoid.new(f(0), f(0), f(0), f(100))
  it "check relative3" do
    rate_value(a, 0, 80, 1000, 2).should be_close(0, delta)
    rate_value(a, 40, 25, 1000, 10).should be_close(0, delta)
    rate_value(a, 80, 25, 1000, 21).should be_close(0, delta)
    rate_value(a, 150, 80, 1000, 11).should be_close(0, delta)
  end
  a = Trapezoid.new(f(40), f(40), f(100), f(100))
  it "check relative4" do
    rate_value(a, 0, 80, 1000, 2).should be_close(0, delta)
    rate_value(a, 40, 25, 1000, 10).should be_close(0, delta)
    rate_value(a, 80, 25, 1000, 21).should be_close(0, delta)
    rate_value(a, 150, 80, 1000, 11).should be_close(0, delta)
  end


  it "estimating" do
    param = Param.new(f(0), f(50), f(100))
    value = ParamValue.new(param)
    rates = RateSet.new(param)
    rates.items.clear
    low = Trapezoid.new(f(0), f(0), f(10), f(50))
    medium = Trapezoid.new(f(0), f(50), f(50), f(100))
    high = Trapezoid.new(f(50), f(90), f(100), f(100))
    rates.items.concat [low, medium, high]
    value.real = f(10)
    rates.estimate(value).should eq(0)
    value.real = f(40)
    rates.estimate(value).should eq(1)
    value.real = f(75)
    rates.estimate(value).should eq(2)
  end

  it "estimating auto" do
    param = Param.new(f(0), f(10), f(100))
    value = ParamValue.new(param)
    rates = RateSet.new(param, 4)
    rates.generate_for(param, 1)
    rates.items.size.should eq(5)

    value.real = f(1)
    rates.estimate(value).should eq(0)
    value.real = f(6)
    rates.estimate(value).should eq(1)
    value.real = f(9)
    rates.estimate(value).should eq(2)
    value.real = f(16)
    value.estimate(rates).should eq(2)
    value.real = f(70)
    rates.estimate(value).should eq(3)
    value.real = f(90)
    rates.estimate(value).should eq(4)
  end

  it "estimating corner" do
    param = Param.new(f(0), f(0), f(10))
    value = ParamValue.new(param)
    rates = RateSet.new(param, 1)

    value.real = f(0)
    rates.estimate(value).should eq(2)
    value.real = f(5)
    rates.estimate(value).should eq(3)
    value.real = f(9)
    rates.estimate(value).should eq(4)

    param = Param.new(f(0), f(10), f(10))
    value = ParamValue.new(param)
    rates = RateSet.new(param, 1)

    value.real = f(0)
    rates.estimate(value).should eq(0)
    value.real = f(5)
    rates.estimate(value).should eq(1)
    value.real = f(10)
    rates.estimate(value).should eq(2)
  end

  it "average" do
    Trapezoid.new(f(0), f(0), f(0), f(1)).average.should be_close(0.333, 0.01)
    Trapezoid.new(f(0), f(1), f(1), f(1)).average.should be_close(0.667, 0.01)
    Trapezoid.new(f(0), f(1), f(2), f(3)).average.should be_close(1.5, 0.01)
    Trapezoid.new(f(0), f(10), f(10), f(30)).average.should be_close(13.333, 0.01)
  end

end
