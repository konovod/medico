require "../grammar.cr"

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
  }.map{|sym| Grammar::Noun.new(parse: s(sym)) }
  N_STATS = Stat.values.size
end
