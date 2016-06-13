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
  LiquidParam.new(ParamName::Sangua),
  LiquidParam.new(ParamName::Flegma),
  LiquidParam.new(ParamName::Chole),
  LiquidParam.new(ParamName::Melanchole),
  BioParam.new(ParamName::Ci, 0, 1, 1),
  BioParam.new(ParamName::Pulse, 40, 70, 100),
  BioParam.new(ParamName::Temperature, 36.6, 42, 36.6)
}

end
