require "./data/skill_data"
require "./grammar"
require "./globals"
require "./doctor"

module Medico
  abstract class Skill
    def self.first_stat : Stat
      @@first_stat
    end

    def self.second_stat : Stat
      @@second_stat
    end

    def self.skill_name : Grammar::Noun
      @@name
    end

    def self.level(doc : Doctor)
      doc.stats[first_stat] + doc.stats[second_stat] / 2 + doc.skills_training[self]
    end

    def self.roll(difficulty, doc : Doctor, random = DEF_RND)
      random.rand*level(doc) > random.rand*difficulty
    end

    def self.to_power(difficulty, doc : Doctor, random = DEF_RND)
      {(random.rand + 0.5)*level(doc) / difficulty, 0.5}.max
    end
  end

  abstract class PassiveSkill < Skill
  end

  abstract class ActiveSkill < Skill
    def self.use_name : String
      @@use_name
    end

    def self.ap : Int32
      @@ap
    end

    def self.possible_actions(doc : Doctor)
      throw "ActiveSkill possible_actions is abstract"
    end

    abstract def apply(doc : Doctor, random = DEF_RND)
  end

  class Gather < ActiveSkill
    def self.possible_actions(doc : Doctor)
      yield new() unless doc.known_flora.empty?
    end

    def apply(doc : Doctor, random = DEF_RND)
      stat_to_int(known_flora.size * self.to_power(100, doc, random)).times do
        subs = known_flora.weighted_sample{|it| 1000 / it.level} #TODO - cache levels in array?
        doc.bag[subs] += 1
      end
    end
  end

  class ApplySubs < ActiveSkill
    getter whom : Biology::Patient
    getter what : Biology::Substance

    def initialize(@whom, @what)
    end

    def possible_actions(doc : Doctor)
      # TODO
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  class AlchemicalTheory < ActiveSkill
    getter used : Array(Biology::Substance)

    def initialize(aused)
      @used = aused.dup
    end

    def possible_actions(doc : Doctor)
      # TODO
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  class PracticalAlchemy < ActiveSkill
    getter what : Alchemy::Recipe

    def initialize(@what)
    end

    def possible_actions(doc : Doctor)
      # TODO
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  class Bibliology < ActiveSkill
    def possible_actions(doc : Doctor)
      # TODO
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  macro active_skill(atype, name, first_stat, second_stat, use_name, ap)
    class {{atype}}
      @@name : Grammar::Noun = s({{name}})
      @@first_stat = {{first_stat}}
      @@second_stat = {{second_stat}}
      @@use_name : String = s({{use_name}}).get #TODO - grammar verbs
      @@ap = {{ap}}
    end
  end

  macro passive_skill(atype, name, first_stat, second_stat)
    class {{atype}} < PassiveSkill
      @@name : Grammar::Noun = s({{name}})
      @@first_stat = {{first_stat}}
      @@second_stat = {{second_stat}}
    end
  end

  skill_data
end
