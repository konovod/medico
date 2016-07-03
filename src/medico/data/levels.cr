CON_LEVELS = {
  {name: :ConLevel1, min: f(0), max: f(5)},
  {name: :ConLevel2, min: f(5), max: f(9)},
  {name: :ConLevel3, min: f(9), max: f(12)},
  {name: :ConLevel4, min: f(12), max: f(15)},
  {name: :ConLevel5, min: f(15), max: f(19)},
}

HEALTH_LEVELS = {
  {name: :Healthy, min: f(1), max: f(2)},
  {name: :SlghtlySick, min: f(0.95), max: f(1)},
  {name: :Sick, min: f(0.90), max: f(0.95)},
  {name: :Diseased, min: f(0.70), max: f(0.90)},
  {name: :HeavyDiseased, min: f(0.50), max: f(0.70)},
  {name: :CriticallyDiseased, min: f(0.25), max: f(0.50)},
  {name: :Hopeless, min: f(0.10), max: f(0.25)},
  {name: :Dying, min: f(0), max: f(0.10)},
}

SKILL_LEVELS = {
  {name: :SkillLevel1, min: f(0), max: f(10)},
  {name: :SkillLevel2, min: f(10), max: f(20)},
  {name: :SkillLevel3, min: f(20), max: f(30)},
  {name: :SkillLevel4, min: f(30), max: f(40)},
  {name: :SkillLevel5, min: f(40), max: f(50)},
  {name: :SkillLevel6, min: f(50), max: f(60)},
}
