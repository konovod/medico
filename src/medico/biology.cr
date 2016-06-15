require "./fuzzy"
require "./data/*"

module Biology
  extend self

  data_bioparams
  data_systems
  data_sympthoms

  class BioParam < Fuzzy::Param
    getter name : Symbol

    def desc
      s(@name)
    end

    def initialize(@name, min, average, max)
      super(f(min), f(average), f(max))
    end
  end

  class LiquidParam < BioParam
    def initialize(name)
      super(name, f(0), f(1) / NLIQUIDS, f(1))
    end
  end

  class Sympthom
    getter name : Symbol
    getter damage : FLOAT
    getter danger : FLOAT
    getter system : Symbol

    def desc
      s(@name)
    end

    def initialize(@system, @name, adanger, adamage)
      @damage = f(adamage)
      @danger = f(adanger)
    end
  end

  class SystemState

    alias TParams = Hash(BioParam, Fuzzy::ParamValue)

    getter sympthoms
    getter params : TParams
    @oldvalues : TParams
    getter name : Symbol


    def initialize(@name)
      @sympthoms = Hash(Sympthom, FLOAT).new
      @params = Hash(BioParam, Fuzzy::ParamValue).new

      ALL_PARAMS.each { |p| @params[p] = Fuzzy::ParamValue.new(p) }
      ALL_SYMPTHOMS.select { |sy| sy.system == @name }.each { |sy| @sympthoms[sy] = f(0) }
      @oldvalues = @params.clone
    end

    def reset
      @params.value.each {|x| x.real = x.owner.average}
      @oldvalues = @params.clone
      @sympthoms.keys.each {|x| @sympthoms[x] = f(0)}
    end
  end

  class Patient
    getter name : String
    getter systems

    def initialize(@name)
      @systems = Hash(Symbol, SystemState).new
      ALL_SYSTEMS.each { |sys| @systems[sys] = SystemState.new(sys) }
    end
  end

  BIO_RATER = ALL_PARAMS.map{|x| RateSet.new(x, 1)}

  abstract class Effect
    abstract def apply(sys : SystemState, power : FLOAT)
  end

  class SympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] = SympthomState::Active if sys.sympthoms[@sympthom] == SympthomState::None
    end
  end

  class RemoveSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] = SympthomState::Inhibited
    end
  end

  class ChangeParam < Effect
    getter param : BioParam
    getter changer : Fuzzy::FuzzySet

    def initialize(@param, @changer)
    end

    def apply(sys : SystemState, power : FLOAT)
      delta = changer.sample(random)

    end

  end


end
