require "./spec_helper"
require "../src/medico/doctor.cr"

include Medico

describe Medico do
  doc = Doctor.new

  doc.generate($r)

  p ALL_SKILLS.first.name.get
end
