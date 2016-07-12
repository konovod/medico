require "./data/skill_data"
require "./grammar"
require "./globals"
require "./doctor"

module Medico
  class Action
  end

  abstract class Skill
    getter id : Symbol
    getter name : Grammar::Noun
    getter first_stat : Stat
    getter second_stat : Stat

    def initialize(@id, @first_stat, @second_stat)
      @name = s(@id)
    end

    def level(doc : Doctor)
      doc.stats[first_stat] + doc.stats[second_stat] / 2 + doc.skills_training[self]
    end

    def roll(difficulty, doc : Doctor, random = DEF_RND)
      random.rand*level(doc) > random.rand*difficulty
    end

    def to_power(difficulty, doc : Doctor, random = DEF_RND)
      {(random.rand + 0.5)*level(doc) / difficulty, 0.5}.max
    end

    abstract def possible_actions(doc : Doctor)
  end

  class PassiveSkill < Skill
    def possible_actions(doc : Doctor)
      # nothing
    end
  end

  abstract class ActiveSkill < Skill
    getter use_name : String
    getter ap : Int32

    def initialize(@id, @first_stat, @second_stat, ause, @ap)
      super(@id, @first_stat, @second_stat)
      @use_name = $s[ause] # TODO verbs
    end
  end

  class Gather < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end
  end

  class ApplySubs < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end
  end

  class AlchemicalTheory < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end
  end

  class PracticalAlchemy < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end
  end

  class Bibliology < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end
  end
end
