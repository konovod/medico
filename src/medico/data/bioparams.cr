macro data_bioparams

enum ParamName
  Sangua
  Flegma
  Chole
  Melanchole
  Ci
  Pulse
  Temperature
end


  NLIQUIDS = 4

  ALL_PARAMS = {
    LiquidParam.new(ParamName::Sangua, "Sangua"),
    LiquidParam.new(ParamName::Flegma, "Flegma"),
    LiquidParam.new(ParamName::Chole, "Chole"),
    LiquidParam.new(ParamName::Melanchole, "Melanchole"),
    BioParam.new(ParamName::Ci, "Ci", 0, 1, 1),
    BioParam.new(ParamName::Pulse, "Pulse", 40, 70, 100),
    BioParam.new(ParamName::Temperature, "Temperature", 36.6, 42, 36.6)
  }

end
