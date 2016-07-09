require "./biology.cr"
require "./generator.cr"
require "./substances.cr"
require "./data/*"

module Medico
  class Player
    getter stats

    def initialize
      @stats = Hash(Stat, Int32).new
    end

    def generate(random = DEF_RND)
      Stat.values.each { |k| @stats[k] = randg(10, 3, random).to_i.clamp(5, 20) }
    end
  end
end
