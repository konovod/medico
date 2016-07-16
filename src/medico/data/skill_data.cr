macro skill_data

  active_skill(Gather, :Gather_name, Stat::Dil, Stat::Intu, :Gather_use, 4)
  active_skill(ApplySubs, :ApplySubs_name, Stat::Acc, Stat::Intu, :ApplySubs_use, 1)
  active_skill(AlchemicalTheory, :SeekRecipe_name, Stat::Intu, Stat::Int, :SeekRecipe_use, 5)
  active_skill(PracticalAlchemy, :MakeRecipe_name, Stat::Acc, Stat::Dil, :MakeRecipe_use, 1)
  active_skill(Bibliology, :ReadBooks_name, Stat::Int, Stat::Dil, :ReadBooks_use, 3)
  passive_skill(GeneralDiagnose, :GeneralDiagnose_name, Stat::Emp, Stat::Intu)
  passive_skill(SpecDiagnose, :SpecDiagnose_name, Stat::Int, Stat::Emp)
  passive_skill(Therapy, :Therapy_name, Stat::Acc, Stat::Emp)
  passive_skill(Haggle, :Haggle_name, Stat::Chr, Stat::Chr)
  passive_skill(Advertising, :Advertising_name, Stat::Chr, Stat::Int)
  passive_skill(SelfDiag, :SelfDiag_name, Stat::Intu, Stat::Dil)
  passive_skill(Hygiene, :Hygiene_name, Stat::Acc, Stat::Acc)

    ALL_SKILLS = {
      Gather,
      GeneralDiagnose,
      ApplySubs,
      AlchemicalTheory,
      PracticalAlchemy,
      Bibliology,
      SpecDiagnose,
      Therapy,
      Haggle,
      Advertising,
      SelfDiag,
      Hygiene,
    }


end
