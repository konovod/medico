module Medico

  ALL_SKILLS = {
    Gather.new(:Gather_name, Stat::Dil, Stat::Intu, :Gather_use, 4),
    PassiveSkill.new(:GeneralDiagnose_name, Stat::Emp, Stat::Intu),
    ApplySubs.new(:ApplySubs_name, Stat::Acc, Stat::Intu, :ApplySubs_use, 1),
    AlchemicalTheory.new(:SeekRecipe_name, Stat::Intu, Stat::Int, :SeekRecipe_use, 5),
    PracticalAlchemy.new(:MakeRecipe_name, Stat::Acc, Stat::Dil, :MakeRecipe_use, 1),
    Bibliology.new(:ReadBooks_name, Stat::Int, Stat::Dil, :ReadBooks_use, 3),
    PassiveSkill.new(:SpecDiagnose_name, Stat::Int, Stat::Emp),
    PassiveSkill.new(:Therapy_name, Stat::Acc, Stat::Emp),
    PassiveSkill.new(:Haggle_name, Stat::Chr, Stat::Chr),
    PassiveSkill.new(:Advertising_name, Stat::Chr, Stat::Int),
    PassiveSkill.new(:SelfDiag_name, Stat::Intu, Stat::Dil),
    PassiveSkill.new(:Hygiene_name, Stat::Acc, Stat::Acc),
  }
end
