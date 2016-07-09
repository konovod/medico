require "./spec_helper"
require "../src/medico/player.cr"

include Medico

describe Medico do

  p = Player.new

  p.generate($r)

end
