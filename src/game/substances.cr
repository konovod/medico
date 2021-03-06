require "./biology"
require "./effectors"
require "./namegen"
require "./grammar"

module Biology
  class Substance < TimedEffector
    getter name : Grammar::Noun
    getter power : Int32
    getter systems : Set(System)
    getter kinetics : Int32
    getter complexity : Int32
    getter reactions
    getter order : Int32

    def initialize(@order, @complexity, @name, @power)
      super()
      @kinetics = 1
      @systems = System.values.to_set
      @reactions = [] of ReactionRule
    end

    def to_s(io)
      io << @name
    end

    def generate(univ : Universe, random = DEF_RND)
      arr = [] of System
      @power.times { arr << System.values.sample(random) }
      @systems = arr.to_set
      @kinetics = 5 + @power + random.rand(2*@power)
      @effects.concat univ.random_effects_sys(0.9, @systems,
        count: @power//2 + 1 + random.rand(@power//2 + 1),
        random: random)
      self
    end

    def inject(patient : Patient, effectivity : FLOAT)
      @systems.map do |sys|
        n = {(effectivity*@kinetics).to_i, 2}.max
        state = patient.systems[sys]
        return if state.effectors.fetch(self, -1) > n
        state.effectors[self] = n
        @reactions.select { |r| r.applicable(state) }.each { |r| state.effectors[r] = 1 }
      end
    end

    def process(**context) : TEffectorData
      val = super(**context)
      if val <= 0
        state = context[:state]
        @reactions.select { |r| !r.applicable(state) }.each { |r| state.effectors.delete(r) }
      end
      val
    end
  end

  class ReactionRule < Effector
    getter substances

    def initialize
      super()
      @substances = Array(Substance).new
    end

    def applicable(state : SystemState)
      @substances.all? { |subs| state.effectors.fetch(subs, 0) >= 1 }
    end

    def process(**context) : TEffectorData
      # TODO ?
      apply(context)
      return 1
    end
  end
end

module Alchemy
  class Recipe
    getter substances
    getter product : Biology::Substance

    def initialize(@product)
      @substances = Hash(Biology::Substance, Int32).new
    end
  end
end
