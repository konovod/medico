require "./data/skill_data"
require "./grammar"
require "./globals"
require "./doctor"

module Medico
  abstract class Skill
    def self.first_stat : Stat
      # raise "Skill is abstract"
      Stat::Int
    end

    def self.second_stat : Stat
      # raise "Skill is abstract"
      Stat::Int
    end

    def self.skill_name : Grammar::Noun
      # raise "Skill is abstract"
      Grammar::Noun.new(parse: "")
    end

    def self.level(doc : Doctor)
      doc.stats[first_stat] + doc.stats[second_stat] / 2 + doc.skills_training[self]
    end

    def self.roll(difficulty, doc : Doctor, random = DEF_RND)
      random.rand*level(doc) > random.rand*difficulty
    end

    def self.to_power(difficulty, doc : Doctor, random = DEF_RND) : FLOAT
      {(f(random.rand) + 0.5)*level(doc) / difficulty, f(0.5)}.max
    end
  end

  abstract class PassiveSkill < Skill
  end

  abstract class ActiveSkill < Skill
    def self.use_name : String
      ""
      # raise "ActiveSkill is abstract"
    end

    def self.ap : Int32
      0
      # raise "ActiveSkill is abstract"
    end

    def self.possible_actions(doc : Doctor, &block)
      # raise "ActiveSkill is abstract"
    end

    abstract def apply(doc : Doctor, random = DEF_RND)
  end

  class Gather < ActiveSkill
    def self.possible_actions(doc : Doctor, &block)
      yield new() unless doc.known_flora.empty?
    end

    def apply(doc : Doctor, random = DEF_RND)
      stat_to_int(doc.known_flora.size * self.class.to_power(100, doc, random), random).times do
        subs = doc.known_flora.weighted_sample(random) { |it| 1000 / it.power } # TODO - cache levels in array?
        doc.bag[subs] += 1
      end
    end
  end

  class ApplySubs < ActiveSkill
    getter whom : Biology::Patient
    getter what : Biology::Substance

    def initialize(@whom, @what)
    end

    def self.possible_actions(doc : Doctor, &block)
      doc.bag.each do |key, value|
        next if value <= 0
        doc.patients.each do |pat|
          yield(new(pat, key))
        end
      end
    end

    def apply(doc : Doctor, random = DEF_RND)
      doc.bag[@what] -= 1
      @what.inject(@whom, self.class.to_power(20, doc, random))
      # TODO - log
    end
  end

  class AlchemicalTheory < ActiveSkill
    getter used : Array(Biology::Substance)

    def initialize(aused)
      @used = aused.dup
    end

    def self.possible_actions(doc : Doctor, &block)
      #has type Hash(Int32, Array(Tuple(Biology::Substance, Int32)))
      numbered = doc.bag.group_by{|subs, count| count}
      keys = numbered.keys.sort
      aset = [] of Biology::Substance
      while !keys.empty?
        next_key = keys.pop
        return if next_key == 0
        aset.concat(numbered[next_key].map{|subs, count| subs})
        yield(new(aset.dup)) if aset.size >= 2
      end
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  class PracticalAlchemy < ActiveSkill
    getter what : Alchemy::Recipe

    def initialize(@what)
    end

    def self.possible_actions(doc : Doctor, &block)
      doc.known_recipes.each do |recipe|
        next unless recipe.substances.all? { |subs, num| doc.bag[subs]? && doc.bag[subs] >= num }
        yield new(recipe)
      end
    end

    def apply(doc : Doctor, random = DEF_RND)
      @what.substances.each do |subs, num|
        doc.bag[subs] -= num
      end
      v = stat_to_int(self.class.to_power(@what.product.power, doc, random))
      doc.bag[@what.product] += v
      # TODO - log
    end
  end

  class Bibliology < ActiveSkill
    def self.possible_actions(doc : Doctor, &block)
      # TODO
    end

    def apply(doc : Doctor, random = DEF_RND)
      # TODO
    end
  end

  macro active_skill(atype, name, first_stat, second_stat, use_name, ap)
    class {{atype}}
     @@name : Grammar::Noun = s({{name}})
      def self.skill_name
       @@name
      end
      def first_stat
        {{first_stat}}
      end
      def second_stat
        {{second_stat}}
      end
      @@use_name : String = s({{use_name}}).get #TODO - grammar verbs
      def self.use_name
        @@use_name
      end
      def self.ap
        {{ap}}
      end
    end
  end

  macro passive_skill(atype, name, first_stat, second_stat)
    class {{atype}} < PassiveSkill
      @@name : Grammar::Noun = s({{name}})
      def self.skill_name
        @@name
      end
      def first_stat
        {{first_stat}}
      end
      def second_stat
        {{second_stat}}
      end
    end
  end

  skill_data
end
