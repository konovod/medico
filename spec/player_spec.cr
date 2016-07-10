require "./spec_helper"
require "../src/medico/doctor.cr"

include Medico

describe Medico do
  doc = Doctor.new

  doc.generate($r)
end
