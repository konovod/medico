require "./spec_helper"
require "../src/medico/game/globals.cr"
require "../src/medico/game/namegen.cr"

it "weighted_sample" do
  {1000, 3, 4, 5, 6, 7}.weighted_sample(SPEC_R) { |i| i }.should eq(1000)
  [-1, -100, -3, 4, 5, 6, 7, -10000].weighted_sample(SPEC_R, &.abs).should eq(-10000)
  ["low", "high", "low2"].weighted_sample([1, 1000, 3], SPEC_R).should eq("high")
  ["low", "high", "low2"].weighted_sample({1, 1000, 3}, SPEC_R).should eq("high")
  {"low", "high", "low2"}.weighted_sample([1, 1000, 3], SPEC_R).should eq("high")
  {"low", "high", "low2"}.weighted_sample({1, 1000, 3}, SPEC_R).should eq("high")
end

def check_namegen(gen, n, str1, str2, maxval, minval)
  gen.history.clear
  amin, amax = maxval, minval
  fl1, fl2 = false, false
  n.times do
    item, val = gen.next(true, SPEC_R)
    fl1 = true if item.get.index(str1)
    fl2 = true if item.get.index(str2)
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

disease_names = NameGen.new(DIS_NAMES1, DIS_NAMES2)
chemical_names = NameGen.new(CHEM_NAMES1, CHEM_NAMES2)

it "names gen" do
  check_namegen(disease_names, 60,
    s(DIS_NAMES1.first[:name], Grammar::Adjective).get(Grammar::Gender::She),
    s(DIS_NAMES2.last[:name]).get, 7, 20)
  check_namegen(chemical_names, 100,
    s(CHEM_NAMES1.first[:name], Grammar::Adjective).get(Grammar::Gender::She),
    s(CHEM_NAMES2.last[:name]).get, 7, 20)
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
  {1, 2, 3}.sorted?.should be_truthy
  {1, 3, 2}.sorted?.should be_falsey
end

it "stat_to_int" do
  n = 0
  1000.times { n += stat_to_int(5.1, SPEC_R) }
  (n/1000.0).should be_close 5.1, 0.05
end

p "utils_spec #{SPEC_R.rand}" if TEST_RANDOM
