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
    item, val = gen.next($r)
    fl1 = true if item.index(str1)
    fl2 = true if item.index(str2)
    amin = val if amin > val
    amax = val if amax < val
  end
  amin.should be < minval
  amax.should be > maxval
  fl1.should be_truthy
  fl2.should be_truthy
  return gen.history.size
end

it "names gen" do
  check_namegen($disease_names, 100, s(DIS_NAMES1.first[:name]), s(DIS_NAMES2.last[:name]), 7, 20).should be < 100
  check_namegen($chemical_names, 100, s(CHEM_NAMES1.first[:name]), s(CHEM_NAMES2.last[:name]), 7, 20).should eq 100
end
