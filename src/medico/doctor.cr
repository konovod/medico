require "./biology.cr"
require "./generator.cr"
require "./substances.cr"
require "./skills.cr"
require "./data/*"

module Medico
  class Doctor
    getter stats
    getter skills_training

    def initialize
      @stats = Hash(Stat, Int32).new
      @skills_training = Hash(Skill, Int32).new
      ALL_SKILLS.each { |sk| @skills_training[sk] = 1 }
    end

    def generate(random = DEF_RND)
      Stat.values.each { |k| @stats[k] = randg(10, 3, random).to_i.clamp(5, 20) }
    end

    def train(skill)
      @skills_training[skill] += stat_to_int(BIO_CONSTS[:TrainRate]) # TODO specific TrainRate
    end
  end
end
