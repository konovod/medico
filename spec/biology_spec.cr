require "./spec_helper"
require "../src/game/biology.cr"
require "../src/game/effectors.cr"

include Biology

describe Biology do
  it "Creating patient" do
    john = Patient.new(SPEC_R)
    john.systems.keys.first.name.should be_truthy
    john.systems.values.first.sympthoms.keys.first.name.get.should be_truthy
    john.systems.values.first.params.get.keys.first.name.get.should be_truthy
    john.systems.values.first.params.get.values.first.real.should be_truthy
  end
  john = Patient.new(SPEC_R)
  asys = Biology::System.values.first
  aparam = ALL_PARAMS.first
  asym = ALL_SYMPTHOMS.select { |sym| sym.system == asys }.first

  it "empty tick" do
    10.times { john.process_tick(SPEC_R) }
    john.systems[asys].params.get[aparam].real.should be_close(0.25, 0.01)
  end

  it "test effector" do
    testeff = ChangeParam.new(aparam, Fuzzy::Pike.new(f(-0.1)))
    testdis = TimedEffector.new
    testdis.effects << testeff

    john.systems[asys].effectors[testdis] = 10
    5.times { john.process_tick(SPEC_R) }
    john.systems[asys].params.get[aparam].real.should be_close(0.15, 0.01)
    10.times { john.process_tick(SPEC_R) }
    john.systems[asys].params.get[aparam].real.should be_close(0.25, 0.01)
  end
  john.reset

  it "param rule" do
    testeff = ChangeParam.new(aparam, Fuzzy::Pike.new(f(-0.25)))
    testdis = TimedEffector.new
    testdis.effects << testeff
    payload = AddSympthomEffect.new(asym)
    testdis2 = ParamRule.new(aparam, BIO_RATER[aparam].items[0])
    testdis2.effects << payload

    john.systems[asys].effectors[testdis] = 10
    john.systems[asys].effectors[testdis2] = 0
    1.times { john.process_tick(SPEC_R) }
    john.systems[asys].sympthoms[asym].should eq(0)
    5.times { john.process_tick(SPEC_R) }
    john.systems[asys].sympthoms[asym].should eq(1)
    # p john.systems[asys].damage
    # p john.systems[asys].danger
    10.times { john.process_tick(SPEC_R) }
    john.systems[asys].sympthoms[asym].should eq(0)
  end

  it "special raters" do
    HEALTH_RATER.estimate_f(0.6).should eq :HeavyDiseased
    CON_RATER.estimate_f(10).should eq :ConLevel3
  end
end

p "biology_spec #{SPEC_R.rand}" if TEST_RANDOM
