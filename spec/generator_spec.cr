require "spec"
require "../src/medico/biology.cr"
require "../src/medico/effectors.cr"
require "../src/medico/generator.cr"

include Biology

$r = Random.new(2)

describe Universe do
  u = Universe.new

  it "init" do
    u.init_effects
    u.diseases_pool.size.should eq(BIO_CONSTS[:NDiseases])
    u.effects_pool.size.should eq(BIO_CONSTS[:NDiseases] + ALL_SYMPTHOMS.size*2 + N_LIQUIDS*4 + 2 + 4 + 2)
  end

  it "random effects" do
    goods = u.random_effects(f(1), random: $r, count: 10)
    goods.any? { |e| e.is_a?(MagicBulletEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(AddSympthomEffect) }.should be_falsey
    goods.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    bads = u.random_effects(f(0), random: $r, count: 10)
    bads.any? { |e| e.is_a?(MagicBulletEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(AddSympthomEffect) }.should be_truthy
    bads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    heads = u.random_effects(f(0.5), random: $r, count: 10, sys: :Brains)
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy
  end

  it "diseases generation" do
    u.init_diseases($r)
    p u.diseases_pool.map{|d|d.systems.size}.sort
    u.diseases_pool.map{|d|d.systems.size}.uniq.sort.should eq((1..ALL_SYSTEMS.size).to_a)

  end

end
