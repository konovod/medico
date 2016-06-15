require "spec"
require "../src/medico/biology.cr"

include Biology

describe Biology do
  it "Creating patient" do
    john = Patient.new("John")  
    s(john.systems.keys.first).should be_truthy
    john.systems.values.first.sympthoms.keys.first.desc.should be_truthy
    john.systems.values.first.params.keys.first.desc.should be_truthy
    john.systems.values.first.params.values.first.real.should be_truthy
  end
  john = Patient.new("John")

end
