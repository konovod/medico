require "spec"
require "../src/medico/biology.cr"
require "../src/medico/generator.cr"

include Biology

$r = Random.new(4)
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
    u.effects_pool.size.should eq(BIO_CONSTS[:NDiseases] + ALL_SYMPTHOMS.size*2 + N_LIQUIDS*4 + 2 + 4 + 2)
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
    #u.param_rules
  end

  it "diseases generation" do
    u.init_diseases($r)
    sys_count = u.diseases_pool.map { |d| d.systems.size }.sort
    p sys_count.group_by { |x| x }.map { |k, v| {k, v.size} }
    sys_count.to_set.superset?((2...ALL_SYSTEMS.size).to_set).should be_truthy
    sys_count.count(2).should be > sys_count.count(1)
    sys_count.count(3).should be > sys_count.count(5)
  end

  john = Patient.new("John", $r)
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
    results[0].should be_close(0, 5)
  end
  puts "ticks simulated #{$performance}, #{($performance * 1.0 / (Time.now - time).total_seconds).to_i} ticks/s"

end
