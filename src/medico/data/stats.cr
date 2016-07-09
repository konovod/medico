module Medico
  enum Stat
    Int
    Emp
    Chr
    Dil
    Intu
  end

  STAT_NAMES = {
    :Int,
    :Emp,
    :Chr,
    :Dil,
    :Intu,
  }
  N_STATS = Stat.values.size
end
