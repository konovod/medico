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

  # TODO autogeneration
  enum Passive
    GeneralDiagnose
    SpecDiagnose
    Therapy
    Haggle
    Advertising
    SelfDiag
    Hygiene
  end

  PASSIVE_SKILLS = {
    Passive::GeneralDiagnose => ALL_SKILLS[1],
    Passive::SpecDiagnose    => ALL_SKILLS[6],
    Passive::Therapy         => ALL_SKILLS[7],
    Passive::Haggle          => ALL_SKILLS[8],
    Passive::Advertising     => ALL_SKILLS[9],
    Passive::SelfDiag        => ALL_SKILLS[10],
    Passive::Hygiene         => ALL_SKILLS[11],
  }
end
