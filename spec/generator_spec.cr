require "spec"
require "../src/medico/biology.cr"
require "../src/medico/generator.cr"

include Biology

$r = Random.new(2)
$performance = 0

def simulate_patient(patient, univ, random, time)
  patient.reset
  dis = univ.diseases_pool.sample(random)
  patient.infect(dis, random)
  time.times do
    patient.process_tick(random)
    $performance += 1
    break if patient.health < 0 || patient.diseases.empty?
  end
  return 1 if patient.diseases.empty?
  #  p patient.diseases[dis].antigene
  return -1 if patient.health < 0
  return 0
end

def stat_patients(univ, random, time, trials)
  counts = {0 => 0.0, 1 => 0.0, -1 => 0.0}
  trials.times do
    john = Patient.new("Test subject", random)
    result = simulate_patient(john, univ, random, time)
    counts[result] += 1
  end
  counts.keys.each { |k| counts[k] = (1.0*counts[k]) / trials * 100 }
  counts
end

describe Universe do
  u = Universe.new

  it "init" do
    u.init_effects
    u.diseases_pool.size.should eq(BIO_CONSTS[:NDiseases])
    u.effects_pool.size.should eq(BIO_CONSTS[:NDiseases] + ALL_SYMPTHOMS.size*2 + N_PARAMS*2*PARAM_DELTA_STAGES - N_UNIMODAL_PARAMS*PARAM_DELTA_STAGES)
  end

  it "random effects" do
    goods = u.random_effects_any(f(1), random: $r, count: 40)
    goods.any? { |e| e.is_a?(MagicBulletEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_truthy
    goods.any? { |e| e.is_a?(AddSympthomEffect) }.should be_falsey
    goods.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    bads = u.random_effects_any(f(0), random: $r, count: 20)
    bads.any? { |e| e.is_a?(MagicBulletEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(RemoveSympthomEffect) }.should be_falsey
    bads.any? { |e| e.is_a?(AddSympthomEffect) }.should be_truthy
    bads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy

    heads = u.random_effects_sys(f(0.5), random: $r, count: 20, sys: Set{:Brains})
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system == :Brains }.should be_truthy
    heads.any? { |e| e.is_a?(AddSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(RemoveSympthomEffect) && e.sympthom.system != :Brains }.should be_falsey
    heads.any? { |e| e.is_a?(ChangeParam) }.should be_truthy
  end

  it "param rules" do
    u.init_param_rules($r)
    u.param_rules.size.should be_close(N_PARAMS*2*PARAM_RATE_STAGES - N_UNIMODAL_PARAMS*PARAM_RATE_STAGES, 5)
    u.param_rules.sum { |r| r.effects.size }.should eq BIO_CONSTS[:NRules]
  end

  it "diseases generation" do
    u.init_diseases($r)
    sys_count = u.diseases_pool.map { |d| d.systems.size }.sort
    puts sys_count.group_by { |x| x }.map { |k, v| "#{v.size} affects #{k} systems" }.join("\n")
    sys_count.to_set.superset?((2...ALL_SYSTEMS.size).to_set).should be_truthy
    sys_count.count(2).should be >= sys_count.count(1)
    sys_count.count(3).should be > sys_count.count(5)
  end

  john = Patient.new("John", $r)
  u.param_rules.each { |r| john.systems.each_value { |sys| sys.effectors[r] = 0 } }

  it "test diseases" do
    # $verbose = true
    3.times { john.infect(u.diseases_pool.sample($r), $r) }
    john.health.should eq(john.maxhealth)
    15.times { john.process_tick($r) }
    john.health.should be < john.maxhealth
    $verbose = false
  end
  it "test reset" do
    john.reset
    john.health.should eq(john.maxhealth)
    1.times { john.process_tick($r) }
    $verbose = true
    15.times { john.process_tick($r) }
    $verbose = false
    john.health.should eq(john.maxhealth)
  end

  $performance = 0
  time = Time.now

  it "test diseases short" do
    results = stat_patients(u, $r, 20, 200)
    puts "stats at initial #{results}"
    results[0].should be_close(100, 15)
  end

  it "test disease long" do
    results = stat_patients(u, $r, 400, 200)
    puts "stats at longtime #{results}"
    results[0].should be < 10
  end
  puts "ticks simulated #{$performance}, #{($performance * 1.0 / (Time.now - time).total_seconds).to_i} ticks/s"

  u.generate_flora($r)
  it "test subs effects" do
    u.flora.sum { |subs| subs.effects.size }.should be_close u.flora.size*3, u.flora.size
    u.flora.sum { |subs| subs.effects.count { |eff| eff.is_a? MagicBulletEffect } }.should be > 10
    u.flora.sum { |subs| subs.effects.count { |eff| eff.is_a? AddSympthomEffect } }.should be_close 10, 9
  end

  it "test injecting" do
    john.reset
    drug = u.flora.sample($r)
    drug.inject(john, f(0.5))
    sys = drug.systems.to_a.sample($r)
    john.systems[sys].effectors[drug].should be_close drug.kinetics/2, 1
  end

  it "test reactions" do
    john.reset

    u.init_reactions(u.flora, $r)
    drug1 = (u.flora.select { |subs| subs.reactions.size > 1 }).sample($r)
    first, second = drug1.reactions[0], drug1.reactions[1]
    first.substances.each &.inject(john, f(1.0))
    sys = (first.substances[0].systems & first.substances[1].systems).to_a.sample($r)
    john.systems[sys].effectors[first]?.should eq 1
    john.systems[sys].effectors[second]?.should be_falsey

    t = first.substances.map(&.kinetics).min + 1
    t.times { john.process_tick($r) }
    john.systems[sys].effectors[first]?.should be_falsey
  end
end
