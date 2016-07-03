
CON_LEVELS = {
{name: :ConLevel1, min: 0, max: 5},
{name: :ConLevel2, min: 5, max: 9},
{name: :ConLevel3, min: 9, max: 12},
{name: :ConLevel4, min: 12, max: 15},
{name: :ConLevel5, min: 15, max: 19},
}

HEALTH_LEVELS = {
  {name: :Healthy, min: 1, max: 2},
  {name: :SlghtlySick, min: 0.95, max: 1},
  {name: :Sick, min: 0.90, max: 0.95},
  {name: :Diseased, min: 0.70, max: 0.90},
  {name: :HeavyDiseased, min: 0.50, max: 0.70},
  {name: :CriticallyDiseased, min: 0.25, max: 0.50},
  {name: :Hopeless, min: 0.10, max: 0.25},
  {name: :Dying, min: 0, max: 0.10},
}

SKILL_LEVELS = {
  {name: :SkillLevel1, min: 0, max: 10},
  {name: :SkillLevel2, min: 10, max: 20},
  {name: :SkillLevel3, min: 20, max: 30},
  {name: :SkillLevel4, min: 30, max: 40},
  {name: :SkillLevel5, min: 40, max: 50},
  {name: :SkillLevel6, min: 50, max: 60},
}
