require "./spec_helper"
require "../src/medico/doctor.cr"
require "../src/medico/generator.cr"

include Medico
include Biology

describe Medico do
  univ = Universe.new
  univ.generate($r)

  doc = Doctor.new(univ)
  doc.generate($r)

  it "skills here" do
    ALL_SKILLS.first.name.get.should be_truthy
    doc.skills_training[ALL_SKILLS.first].should be_truthy
  end

  it "lazy doctor" do
    10.times { doc.next_day($r) }
  end
end
