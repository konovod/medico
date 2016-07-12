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
    getter fame
    getter money
    getter patients
    getter askers
    getter corpses

    def initialize
      @stats = Hash(Stat, Int32).new
      @skills_training = Hash(Skill, Int32).new
      ALL_SKILLS.each { |sk| @skills_training[sk] = 1 }
      @patients = Array(Biology::Patient).new
      @askers = Array(Biology::Patient).new
      @corpses = Array(Biology::Patient).new
      @ap = MAX_AP
      @day = 1
      @fame = 0
      @money = 100
    end

    def generate(random = DEF_RND)
      Stat.values.each { |k| @stats[k] = randg(10, 3, random).to_i.clamp(5, 20) }
    end

    def train(skill, random = DEF_RND)
      @skills_training[skill] += stat_to_int(CONFIG[:TrainRate], random) # TODO specific TrainRate
    end

    def skill_power(name : Passive, difficulty, random = DEF_RND, *, should_train : Bool = true)
      sk = PASSIVE_SKILLS[name]
      result = sk.to_power(difficulty, self, random)
      train(sk, random) if should_train
      result
    end

    def skill_roll(name : Passive, difficulty, random = DEF_RND, *, should_train : Bool = true)
      sk = PASSIVE_SKILLS[name]
      result = sk.roll(difficulty, self, random)
      train(sk, random) if should_train
      result
    end

    def next_day(random = DEF_RND)
      # 1 - corpses
      @corpses.clear
      # 2 - patients
      @patients.each &.process_tick(random)
      @patients.reject! do |pat|
        if pat.dead
          @corpses << pat
          @fame += Social.fame_change(self, pat, false, random)
        elsif pat.feels_good
          @fame += Social.fame_change(self, pat, true, random)
        end
        pat.dead || pat.feels_good
      end
      # 3 - askers
      @askers.each &.process_tick(random)
      @askers.reject! do |pat|
        pat.dead || pat.is_good || random.rand < 0.01
      end
      if skill_roll(Passive::Advertising, 10, random, should_train: false)
        pat = Social.gen_patient(self, random)
        @askers << pat unless pat.nil?
      end
      # 4 - final
      @ap = MAX_AP
      @day += 1
    end
  end
end
