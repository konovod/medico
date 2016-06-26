require "./biology"
require "./effectors"
require "./namegen"

module Biology

  class Substance < TimedEffector
    getter name : String
    getter power : Int32
    getter systems : Set(Symbol)
    getter kinetics : Int32

    def initialize(@name, @power)
      super()
      @kinetics = 1
      @systems = ALL_SYSTEMS.to_set
    end

    def to_s(io)
      io << @name
    end

    def generate(univ : Universe, random = DEF_RND)
      n = random.rand(ALL_SYSTEMS.size + 1) + 2
      arr = [] of Symbol
      @power.times { arr << ALL_SYSTEMS.to_a.sample(random) }
      @systems = arr.to_set
      @kinetics = 5+@power+random.rand(2*@power)
      @effects.concat univ.random_effects_sys(f(0.9), @systems.to_a,
        count: @power/2+1+random.rand(@power/2+1),
        random: random)
    end


  end

  class ReactionRule < Effector
    getter substances

    def initialize
      super()
      substances = Array(Substance).new
    end

    def process(**context) : TEffectorData
      #TODO
      return -1
    end

  end
end

module Alchemy
  class Recipe
    getter substances
    getter product : Substance

    def initialize(@product)
      @substances = Hash(Substance, Int32).new
    end

  end

end
