macro data_bioparams

N_LIQUIDS = 4
N_PARAMS = 7

ALL_PARAMS = {
  LiquidParam.new(:Sangua),
  LiquidParam.new(:Flegma),
  LiquidParam.new(:Chole),
  LiquidParam.new(:Melanchole),
  BioParam.new(:Ci, 0, 1, 1),
  BioParam.new(:Pulse, 40, 70, 100),
  BioParam.new(:Temperature, 36.6, 42, 36.6)
}

end
