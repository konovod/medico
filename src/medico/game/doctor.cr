require "./biology.cr"
require "./universe.cr"
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
    getter universe : Biology::Universe
    getter known_flora
    getter known_recipes
    getter bag
    getter actions

    def initialize(@universe)
      @stats = Hash(Stat, Int32).new
      @skills_training = Hash(Skill.class, Int32).new
      ALL_SKILLS.each do |sk|
        @skills_training[sk] = 1
      end
      # @skills_training = ALL_SKILLS.map{|sk| {sk, 1} }.to_h
      @patients = Array(Biology::Patient).new
      @askers = Array(Biology::Patient).new
      @corpses = Array(Biology::Patient).new
      @ap = MAX_AP
      @day = 1
      @fame = 1
      @money = 100
      @known_flora = Set(Substance).new
      @known_recipes = Set(Alchemy::Recipe).new
      @bag = Hash(Substance, Int32).new(0)
      @actions = Array(ActiveSkill).new
    end

    def generate(random = DEF_RND)
      Stat.values.each { |k| @stats[k] = randg(10, 3, random).to_i.clamp(5, 20) }
    end

    def start_game(random = DEF_RND)
      10.times do
        add_asker(random)
      end
      while @askers.size < 3
        add_asker(random)
      end
      starting_flora = @universe.flora.sample(10, random)
      starting_flora.each do |fl|
        add_known_substance(fl, is_flora: true, value: random.rand(5) + 1, random: random)
      end
      check_actions
    end

    def train(skill, random = DEF_RND)
      @skills_training[skill] += stat_to_int(CONFIG[:TrainRate], random) # TODO specific TrainRate
    end

    def skill_power(sk, difficulty, random = DEF_RND, *, should_train : Bool = true)
      result = sk.to_power(difficulty, self, random)
      train(sk, random) if should_train
      result
    end

    def skill_roll(sk, difficulty, random = DEF_RND, *, should_train : Bool = true)
      result = sk.roll(difficulty, self, random)
      train(sk, random) if should_train
      result
    end

    def add_asker(random = DEF_RND)
      pat = Social.gen_patient(self, random)
      unless pat.nil?
        @universe.generate_infection(pat, random)
        @askers << pat
      end
    end

    def make_patient(whom : Patient)
      # TODO - log, CaseID
      whom.starting_health = whom.health
      askers.delete(whom)
      patients << whom
      check_actions
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
      add_asker(random) if skill_roll(Advertising, 10, random, should_train: false)
      # 4 - final
      @ap = MAX_AP
      @day += 1
      check_actions
    end

    def check_actions
      @actions.clear
      ALL_SKILLS.each do |sk|
        next unless sk.responds_to? :possible_actions && @ap >= sk.ap
        sk.possible_actions(self) do |act|
          @actions << act
        end
      end
    end

    def do_action(act : ActiveSkill, random = DEF_RND)
      act.apply(self, random)
      @ap -= act.class.ap
      train(act.as(Skill).class, random)
      check_actions
    end

    def add_known_substance(substance : Biology::Substance, *, is_flora = false, value = 0, random = DEF_RND)
      @universe.generate_recipes(@bag.keys, substance, random)
      @universe.init_reactions(@bag.keys, random) # TODO - additive reactions generation
      @known_flora << substance if is_flora
      @bag[substance] = value
    end
  end
end
