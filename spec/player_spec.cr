require "./spec_helper"
require "../src/medico/doctor.cr"
require "../src/medico/universe.cr"

include Medico
include Biology

describe Medico do
  univ = Universe.new
  univ.generate($r)

  doc = Doctor.new(univ)
  doc.generate($r)

  it "skills here" do
    ALL_SKILLS.first.skill_name.get.should be_truthy
    doc.skills_training[ALL_SKILLS.first].should be_truthy
  end
  it "skill checks" do
    sk = ALL_SKILLS.first
    first = doc.skill_power(sk, 1, $r, should_train: false)
    first.should be > 0
    1000.times { doc.skill_power(sk, 1, $r, should_train: true) }
    second = doc.skill_power(sk, 2, $r, should_train: false)
    second.should be > first
  end

  cnt = 0
  it "initial askers" do
    50.times do
      doc.askers.clear
      10.times do
        doc.add_asker($r)
      end
      cnt += doc.askers.size
      # doc.askers.size.should be > 1
    end
  end
  cnt.should be_close 3*50, 50

  it "lazy doctor askers" do
    cnt = 0
    100.times do
      doc.askers.clear
      doc.next_day($r)
      cnt += 1 if doc.askers.size > 0
    end
    cnt.should be > 5
  end

  it "start game" do
    doc.start_game($r)
    doc.askers.size.should be >= 3
    doc.known_flora.size.should eq 10
  end

  doc.check_actions
  it "possible actions" do
    doc.actions.size.should be > 0
    doc.actions.find { |act| act.is_a? Gather }.should be_truthy
    doc.actions.find { |act| act.is_a? ApplySubs }.should be_falsey
  end

  it "make patient" do
    n1 = doc.askers.size
    n2 = doc.patients.size
    target = doc.askers.first
    doc.make_patient(target)
    doc.askers.size.should eq n1 - 1
    doc.patients.size.should eq n2 + 1
    doc.actions.count { |act| act.is_a? ApplySubs }.should eq doc.bag.keys.size
  end

  it "apply substance" do
    action = doc.actions.find { |act| act.is_a? ApplySubs }.as(ApplySubs)
    old = doc.bag[action.what]
    action.whom.systems.values.any? { |sys| sys.effectors[action.what]? }.should be_falsey
    doc.do_action(action, $r)
    doc.bag[action.what].should eq old - 1
    action.whom.systems.values.any? { |sys| sys.effectors[action.what]? }.should be_truthy
  end

  it "gather flora" do
    action = doc.actions.find { |act| act.is_a? Gather }.as(Gather)
    old = doc.bag.values.sum
    doc.do_action(action, $r)
    doc.bag.values.sum.should be > old
  end

  it "ap usage" do
    doc.ap.should eq MAX_AP - ApplySubs.ap - Gather.ap
  end
  it "ap checking" do
    10.times { doc.do_action(doc.actions.first, $r) unless doc.actions.empty? }
    doc.actions.size.should eq 0
  end
  it "ap restoring" do
    doc.next_day($r)
    doc.ap.should eq MAX_AP
  end

  it "alchemical search possible_actions" do
    variants = doc.actions.select { |x| x.is_a? AlchemicalTheory }
    variants.size.should be > 1
    first = variants.first.as(AlchemicalTheory)
    last = variants.last.as(AlchemicalTheory)
    first.used.size.should be < last.used.size
    last.used.should contain(first.used.first)
    last.used.size.should eq doc.bag.count { |k, v| v >= 0 }
  end

  it "AlchemicalTheory application" do
    was_in_bag = doc.bag.values.sum
    all_in = doc.actions.select { |x| x.is_a? AlchemicalTheory }.last.as(AlchemicalTheory)
    doc.do_action(all_in, $r)
    doc.bag.values.sum.should eq was_in_bag - all_in.used.size
  end
  it "AlchemicalTheory works" do
    100.times do
      doc.next_day($r)
      gather = doc.actions.select { |x| x.is_a? Gather }.first
      doc.do_action(gather, $r)
      seek = doc.actions.select { |x| x.is_a? AlchemicalTheory }
      doc.do_action(seek.last, $r)
      combine = doc.actions.select { |x| x.is_a? PracticalAlchemy }
      doc.do_action(combine.sample($r), $r) unless combine.empty?
    end
    doc.known_recipes.size.should be > 0
  end
end
