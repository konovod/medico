require "spec"
require "../src/medico/biology.cr"
require "../src/medico/generator.cr"

include Biology

$r = Random.new(2)

def possible_substances(univ, stash : Set(Substance)) : Set(Substance)
  result = Set(Substance).new
  result.merge stash
  univ.recipes.each do |r|
    result << r.product if (!result.includes?(r.product)) && r.substances.all? { |k, v| result.includes? k }
  end
  result
end

def recipe_stats(univ, nsubs, ntries)
  stats = [] of Tuple(Int32, Int32)
  ntries.times do
    univ.reset_recipes
    baseset = univ.flora.sample(nsubs, $r)
    aset = [baseset.pop]
    univ.init_substances(aset, $r)
    loop do
      oldsize = aset.size
      aset << baseset.pop unless baseset.empty?
      res = possible_substances(univ, aset.to_set)
      res.each do |subs|
        univ.generate_recipes(aset, subs, $r)
        aset << subs
        break if aset.size > 80
      end
      aset.uniq!
      break if aset.size == oldsize
      break if aset.size > 80
    end
    stats << {aset.size, aset.map(&.complexity).max}
  end
  r = stats.reduce([0, 0]) { |sum, tup| [sum[0] + tup[0], sum[1] + tup[1]] }
  [1.0*r[0] / ntries - nsubs, 1.0*r[1] / ntries]
end

describe Universe do
  u = Universe.new
  u.init_effects
  it "substances gen" do
    t = Time.now
    #    possible_substances(u, u.flora.to_set).size.should eq u.flora.size+u.chemicals.size
    p recipe_stats(u, 6, 3)
    p recipe_stats(u, 6, 10)
    p recipe_stats(u, 10, 10)
    p recipe_stats(u, 20, 10)
    # recipe_stats(u, 6, 3).first.should be > 0
    # recipe_stats(u, 6, 100).first.should be > 1
    # recipe_stats(u, 10, 100).first.should be > 4
    # recipe_stats(u, 20, 100).last.should be > 2.5
    #    recipe_stats(u, 40, 100).last.should be > 3.5
    #    p u.chemicals.map(&.complexity).max
  end
end
