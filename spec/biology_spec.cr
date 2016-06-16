require "spec"
require "../src/medico/biology.cr"

include Biology

R = Random.new(1)

describe Biology do
  it "Creating patient" do
    john = Patient.new("John")
    s(john.systems.keys.first).should be_truthy
    john.systems.values.first.sympthoms.keys.first.desc.should be_truthy
    john.systems.values.first.params.get.keys.first.desc.should be_truthy
    john.systems.values.first.params.get.values.first.real.should be_truthy
  end
  john = Patient.new("John")

  it "empty tick" do
    10.times{john.process_tick}
    john.systems.values.first.params.get.values.first.real.should be_close(0.25, 0.01)
  end

  it "test effector" do
    asys = ALL_SYSTEMS.first
    aparam = ALL_PARAMS.first
    testeff = ChangeParam.new(aparam, Fuzzy::Pike.new(f(-0.1)))
    testdis = TimedEffector.new()
    testdis.effects << testeff

    john.systems[asys].effectors[testdis] = 10
    5.times{john.process_tick}
    john.systems.values.first.params.get.values.first.real.should be_close(0.15, 0.01)
    10.times{john.process_tick}
    john.systems.values.first.params.get.values.first.real.should be_close(0.25, 0.01)
  end


end
