require "spec"
require "../src/medico/biology.cr"

include Biology

describe Biology do

  it "Creating patient" do
    john = Patient.new("John")
  end

end
