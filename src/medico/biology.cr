require "./fuzzy"
require "./data/*"

module Biology
  extend self

  data_bioparams
  data_systems
  data_sympthoms


  class BioParam < Fuzzy::Param
    getter name : ParamName
    getter desc : String
    def initialize(@name, @desc, min, average, max)
      super(f(min), f(average), f(max))
    end
  end

  class LiquidParam < BioParam
    def initialize(name, desc)
      super(name, desc, f(0),f(1) / NLIQUIDS, f(1))
    end
  end


  class Sympthom
    getter name : String
    getter damage : FLOAT
    getter danger : FLOAT
    getter system : System

    def initialize(@system, @name, adanger, adamage)
      @damage = f(adamage)
      @danger = f(adanger)
    end
  end



  class SystemState
    getter sympthoms
    getter params

    def initialize(asystem : System)
      @sympthoms = Hash(Sympthom, Bool).new
      @params = Hash(BioParam, Fuzzy::ParamValue).new
      ALL_PARAMS.each {|p| @params[p] = Fuzzy::ParamValue.new(p)}
      ALL_SYMPTHOMS.select{|sy| sy.system == asystem }.each{|sy| @sympthoms[sy] = false}
    end
  end

  class Patient
    getter name : String
    getter systems

    def initialize(@name)
      @systems = Hash(System, SystemState).new
      System.values.each {|sys| @systems[sys] = SystemState.new(sys) }
    end
  end

end
