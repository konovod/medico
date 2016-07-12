require "./spec_helper"
require "../src/medico/doctor.cr"

include Medico

describe Medico do
  doc = Doctor.new

  doc.generate($r)

  it "skills here" do
    ALL_SKILLS.first.name.get.should be_truthy
    doc.skills_training[ALL_SKILLS.first].should be_truthy
  end

  it "lazy doctor" do
    10.times { doc.next_day($r) }
  end
end
