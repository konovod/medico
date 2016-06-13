require "./fuzzy"

module Biology
  extend self

  enum ParamName
    Sangua
    Flegma
    Chole
    MelanChole
    Ci
    Pulse
    Temperature
  end

  NLIQUIDS = 4


  class BioParam < Fuzzy::Param
    getter name : ParamName
    getter desc : String
    def initialize(@name, @desc, min, average, max)
      super(min, average, max)
    end
  end

  class LiquidParam < BioParam
    def initialize(name, desc)
      super(name, desc, f(0),f(1) / NLIQUIDS, f(1))
    end
  end



  ALL_PARAMS = {
    LiquidParam.new(Sangua, "Кровь"),
    LiquidParam.new(Flegma, "Флегма"),
    LiquidParam.new(Chole, "Желчь"),
    LiquidParam.new(MelanChole, "Черная желчь"),
    BioParam.new(Ci, "Поток Ки"),
    BioParam.new(Pulse, "Пульс"),
    BioParam.new(Temperature, "Температура")
  }

  enum System
    Circulatory
    Digestion
    Joints
    Lungs
    Brains
    LOR
  end



  class Sympthom

  end



  class SystemState
    getter sympthoms
    getter params

    def initialize()
      @sympthoms = Hash(Sympthom, Bool).new
      @params = Hash(BioParam, Fuzzy::ParamValue).new
      ALL_PARAMS.each {|p| @params[p] = false}
    end

  end



end
