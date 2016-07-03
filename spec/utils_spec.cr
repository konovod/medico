require "spec"
require "../src/medico/globals.cr"
require "../src/medico/namegen.cr"

$r = Random.new(2)

it "weighted_sample" do
  weighted_sample([1000, 3, 4, 5, 6, 7], $r) { |i| i }.should eq(1000)
  weighted_sample([-1, -100, -3, 4, 5, 6, 7, -10000], $r, &.abs).should eq(-10000)
  weighted_sample(["low", "high", "low2"], [1, 1000, 3], $r).should eq("high")
end

def check_namegen(gen, n, str1, str2, maxval, minval)
  gen.history.clear
  amin, amax = maxval, minval
  fl1, fl2 = false, false
  n.times do
    item, val = gen.next(true, $r)
    fl1 = true if item.index(str1)
    fl2 = true if item.index(str2)
    amin = val if amin > val
    amax = val if amax < val
  end
  amin.should be < minval
  amax.should be > maxval
  fl1.should be_truthy
  fl2.should be_truthy
  gen.history.size.should eq n
  gen.history.clear
end

it "names gen" do
  check_namegen($disease_names, 60, s(DIS_NAMES1.first[:name]), s(DIS_NAMES2.last[:name]), 7, 20)
  check_namegen($chemical_names, 100, s(CHEM_NAMES1.first[:name]), s(CHEM_NAMES2.last[:name]), 7, 20)
end

it "combination" do
  n = 10
  each_combination(3, ["a", "b", "c", "d"]) do |v|
    n = n - 1
    if n == 0
      v.should eq({"b", "c", "d"})
    end
  end
  n.should eq 10 - 24
  n = 10
  each_combination(4, ["a", "b", "c", "d", "e"]) do |v|
    n = n - 1
    if n <= 0
      v.should eq({"a", "c", "d", "e"})
      break
    end
  end
end

it "sorted?" do
  sorted?({1, 2, 3}).should be_truthy
  sorted?({1, 3, 2}).should be_falsey
end
