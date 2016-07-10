require "./spec_helper"
require "../src/medico/player.cr"

include Medico

describe Medico do
  doc = Doctor.new

  doc.generate($r)
end
