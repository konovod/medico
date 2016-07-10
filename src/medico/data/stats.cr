require "../grammar.cr"

module Medico
  enum Stat
    Int
    Emp
    Chr
    Dil
    Intu
    Acc
  end

  STAT_NAMES = {
    :Int,
    :Emp,
    :Chr,
    :Dil,
    :Intu,
    :Acc,
  }.map { |sym| s(sym) }
  N_STATS = Stat.values.size
end
