require "spec"
require "../src/medico/biology.cr"
require "../src/medico/effectors.cr"

include Biology

$r = Random.new(2)

describe Biology do
  it "Creating patient" do
    john = Patient.new("John")
    s(john.systems.keys.first).should be_truthy
    john.systems.values.first.sympthoms.keys.first.desc.should be_truthy
    john.systems.values.first.params.get.keys.first.desc.should be_truthy
    john.systems.values.first.params.get.values.first.real.should be_truthy
  end
  john = Patient.new("John")
  asys = ALL_SYSTEMS.first
  aparam = ALL_PARAMS.first
  asym = ALL_SYMPTHOMS.select { |sym| sym.system == asys }.first

  it "empty tick" do
    10.times { john.process_tick($r) }
    john.systems[asys].params.get[aparam].real.should be_close(0.25, 0.01)
  end

  it "test effector" do
    testeff = ChangeParam.new(aparam, Fuzzy::Pike.new(f(-0.1)))
    testdis = TimedEffector.new
    testdis.effects << testeff

    john.systems[asys].effectors[testdis] = 10
    5.times { john.process_tick($r) }
    john.systems[asys].params.get[aparam].real.should be_close(0.15, 0.01)
    10.times { john.process_tick($r) }
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
    1.times { john.process_tick($r) }
    john.systems[asys].sympthoms[asym].should eq(0)
    5.times { john.process_tick($r) }
    john.systems[asys].sympthoms[asym].should eq(1)
    #p john.systems[asys].damage
    #p john.systems[asys].danger
    10.times { john.process_tick($r) }
    john.systems[asys].sympthoms[asym].should eq(0)
  end
end
