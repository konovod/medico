require "./data/skill_data"
require "./grammar"
require "./globals"
require "./doctor"

module Medico
  class PassiveSkill
    getter id : Symbol
    getter name : Grammar::Noun
    getter first_stat : Stat
    getter second_stat : Stat

    def initialize(@id, @first_stat, @second_stat)
      @name = s(@id)
    end
  end

  class ActiveSkill < PassiveSkill
    getter use_name : String
    getter ap : Int32

    def initialize(@id, @first_stat, @second_stat, ause, @ap)
      super
      @use_name = $s[ause] # TODO verbs
    end
  end

  class Gather < ActiveSkill
  end

  class ApplySubs < ActiveSkill
  end

  class AlchemicalTheory < ActiveSkill
  end

  class PracticalAlchemy < ActiveSkill
  end

  class Bibliology < ActiveSkill
  end
end
