require "spec"
require "../src/medico/biology.cr"
require "../src/medico/effectors.cr"
require "../src/medico/generator.cr"

include Biology

$r = Random.new(2)

describe Universe do

  it "init" do
    u = Universe.new
    u.init_effects
    u.diseases_pool.size.should eq(BIO_CONSTS[:NDiseases])
    u.effects_pool.size.should eq(BIO_CONSTS[:NDiseases]+ALL_SYMPTHOMS.size*2+N_LIQUIDS*4+2+4+2)
  end

end
