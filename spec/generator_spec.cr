require "./spec_helper"
require "../src/medico/game/biology.cr"
require "../src/medico/game/universe.cr"

include Biology

class Performance
  class_property value = 0
end

def simulate_patient(patient, univ, random, time)
  patient.reset
  dis = univ.diseases_pool.sample(random)
  patient.infect(dis, random)
  time.times do
    patient.process_tick(random)
    Performance.value += 1
    break if patient.dead || patient.diseases.empty?
  end
  return 1 if patient.diseases.empty?
  return -1 if patient.dead
  return 0
end

def stat_patients(univ, random, time, trials)
  counts = {0 => 0.0, 1 => 0.0, -1 => 0.0}
  trials.times do
    john = Patient.new(random)
    result = simulate_patient(john, univ, random, time)
    counts[result] += 1
  end
  counts.keys.each { |k| counts[k] = counts[k] / trials * 100 }
  counts
end

describe Universe do
  u = Universe.new

  it "init" do
    u.init_effects
    u.diseases_pool.size.should eq(CONFIG[:NDiseases])
    u.effects_pool.size.should eq(CONFIG[:NDiseases] + ALL_SYMPTHOMS.size*2 + N_PARAMS*2*PARAM_DELTA_STAGES - N_UNIMODAL_PARAMS*PARAM_DELTA_STAGES)
  end

  it "random effects" do
    goods = u.random_effects_any(f(1), random: SPEC_R, count: 40)
    goods.any? { |e| e.is_a?(MagicBulletEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(AddSympthomEffect) }.should be_falsey
    goods.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    bads = u.random_effects_any(f(0), random: SPEC_R, count: 20)
    bads.any? { |e| e.is_a?(MagicBulletEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(AddSympthomEffect) }.should be_truthy
    bads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    heads = u.random_effects_sys(f(0.5), random: SPEC_R, count: 20, sys: Set{Biology::System::Brains})
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system == Biology::System::Brains }.should be_truthy
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system == Biology::System::Brains }.should be_truthy
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system != Biology::System::Brains }.should be_falsey
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system != Biology::System::Brains }.should be_falsey
    heads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy
  end

  it "param rules" do
    u.init_param_rules(SPEC_R)
    u.param_rules.size.should be_close(N_PARAMS*2*PARAM_RATE_STAGES - N_UNIMODAL_PARAMS*PARAM_RATE_STAGES, 5)
    u.param_rules.sum { |r| r.effects.size }.should eq CONFIG[:NRules]
  end

  it "diseases generation" do
    u.init_diseases(SPEC_R)
    sys_count = u.diseases_pool.map { |d| d.systems.size }.sort
    # puts sys_count.group_by { |x| x }.map { |k, v| "#{v.size} affects #{k} systems" }.join("\n")
    (2...Biology::System.values.size).each do |i|
      sys_count.should contain(i)
    end
    sys_count.count(2).should be >= sys_count.count(1)
    sys_count.count(3).should be > sys_count.count(6)
  end

  john = Patient.new(SPEC_R)
  u.param_rules.each { |r| john.systems.each_value { |sys| sys.effectors[r] = 0 } }

  it "test diseases" do
    3.times { john.infect(u.diseases_pool.sample(SPEC_R), SPEC_R) }
    john.health.should eq(john.maxhealth)
    15.times { john.process_tick(SPEC_R) }
    john.health.should be < john.maxhealth
  end

  it "test reset" do
    john.reset
    john.health.should eq(john.maxhealth)
    1.times { john.process_tick(SPEC_R) }
    Log.level = Logger::DEBUG
    15.times { john.process_tick(SPEC_R) }
    Log.level = Logger::INFO
    john.health.should eq(john.maxhealth)
  end

  Performance.value = 0
  time = Time.utc

  it "test diseases short" do
    results = stat_patients(u, SPEC_R, 20, 200)
    # puts "stats at initial #{results}"
    results[0].should be_close(100, 15)
  end

  it "test disease long" do
    results = stat_patients(u, SPEC_R, 400, 200)
    # puts "stats at longtime #{results}"
    results[0].should be < 15
  end
  it "simulation performance" do
    speed = (Performance.value / (Time.utc - time).total_seconds).to_i
    puts "ticks simulated #{Performance.value}, #{speed} ticks/s"
    speed.should be > 10000
  end

  it "test subs effects" do
  u.generate_flora(SPEC_R)
    u.flora.sum { |subs| subs.effects.size }.should be_close u.flora.size*3, u.flora.size
    u.flora.sum { |subs| subs.effects.count { |eff| eff.is_a? MagicBulletEffect } }.should be > 10
    u.flora.sum { |subs| subs.effects.count { |eff| eff.is_a? AddSympthomEffect } }.should be > 1
  end

  it "test injecting" do
    john.reset
    drug = u.flora.sample(SPEC_R)
    drug.inject(john, f(0.5))
    sys = drug.systems.to_a.sample(SPEC_R)
    john.systems[sys].effectors[drug].should be_close drug.kinetics/2, 1
  end

  it "test reactions" do
    john.reset

    u.init_reactions(u.flora, SPEC_R)
    drug1 = (u.flora.select { |subs| subs.reactions.size > 1 }).sample(SPEC_R)
    first, second = drug1.reactions[0], drug1.reactions[1]
    first.substances.each &.inject(john, f(1.0))
    sys = (first.substances[0].systems & first.substances[1].systems).to_a.sample(SPEC_R)
    state = john.systems[sys]
    state.effectors[first]?.should eq 1
    state.effectors[second]?.should be_falsey
    1.times { john.process_tick(SPEC_R) }
    state.effectors[first]?.should eq 1
    t = first.substances.map(&.kinetics).min
    t.times { john.process_tick(SPEC_R) }
    state.effectors[first]?.should be_falsey
  end
end

p "generator_spec #{SPEC_R.rand}" if TEST_RANDOM
