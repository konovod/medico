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
end
