require "spec"
require "../src/medico/biology.cr"
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

    heads = u.random_effects(f(0.5), random: $r, count: 10, sys: Set{:Brains})
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy
  end

  it "diseases generation" do
    u.init_diseases($r)
    sys_count = u.diseases_pool.map{|d|d.systems.size}.sort
    #p sys_count.group_by{|x| x}.map{|k, v| {k, v.size}}
    sys_count.to_set.superset?((1...ALL_SYSTEMS.size).to_set).should be_truthy
    (sys_count.count(2) > sys_count.count(1)).should eq(true)
    (sys_count.count(3) > sys_count.count(5)).should eq(true)
  end

  john = Patient.new("John", $r)
  it "test diseases" do
    dis = u.diseases_pool.sample($r)
    john.infect(dis, $r)
    john.health.should eq(john.maxhealth)
    20.times { john.process_tick($r)}
    (john.health < john.maxhealth).should be_truthy
  end

  it "test diseases2" do
    john.reset
    dis = u.diseases_pool.sample($r)
    john.infect(dis, $r)
    john.health.should eq(john.maxhealth)
    20.times { john.process_tick($r)}
    (john.health < john.maxhealth).should be_truthy
  end

  it "test disease long" do
    20.times do
      john.reset
      dis = u.diseases_pool.sample($r)
      john.infect(dis, $r)
      john.health.should eq(john.maxhealth)
      200.times { john.process_tick($r)}
      p john.health
    end
  end
end
