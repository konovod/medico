require "./biology.cr"
require "./generator.cr"
require "./substances.cr"
require "./skills.cr"
require "./data/*"

module Medico
  MAX_AP = 10

  class Doctor
    getter stats
    getter skills_training
    # todo - World class?
    getter ap
    getter day
    getter patients
    getter askers
    getter corpses

    def initialize
      @stats = Hash(Stat, Int32).new
      @skills_training = Hash(Skill, Int32).new
      ALL_SKILLS.each { |sk| @skills_training[sk] = 1 }
      @patients = Array(Patient).new
      @askers = Array(Patient).new
      @corpses = Array(Patient).new
      @ap = MAX_AP
      @day = 1
    end

    def generate(random = DEF_RND)
      Stat.values.each { |k| @stats[k] = randg(10, 3, random).to_i.clamp(5, 20) }
    end

    def train(skill)
      @skills_training[skill] += stat_to_int(BIO_CONSTS[:TrainRate]) # TODO specific TrainRate
    end

    def skill_power(name : Passive, difficulty, random = DEF_RND, *, should_train : Bool = true)
      sk = PASSIVE_SKILLS[name]
      result = sk.to_power(difficulty, self, random)
      train(sk) if should_train
    end

    def skill_roll(name : Passive, difficulty, random = DEF_RND, *, should_train : Bool = true)
      sk = PASSIVE_SKILLS[name]
      result = sk.roll(difficulty, self, random)
      train(sk) if should_train
    end

    def next_day(random = DEF_RND)
      @corpses.clear
      @patients.each &.process_tick(random)
      @patients.each do |pat|
      end

      @ap = MAX_AP
      @day += 1
    end
  end
end
