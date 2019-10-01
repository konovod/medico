module Grammar
  class Noun
    def for_json
      to_s
    end
  end
end

module Alchemy
  class Recipe
    def for_json
      {product:    @product.name.for_json,
       substances: @substances.map { |k, v| {k.name.for_json, v} },
      }
    end
  end
end

module Medico
  class ActiveSkill
    def for_json
      {skill: self.class.skill_name.for_json,
       name:  self.class.use_name,
       ap:    self.class.ap,
      }
    end
  end

  class Doctor
    def for_json
      {
        stats:         @stats.map { |st, value| {STAT_NAMES[st.to_i].for_json, value} }.to_h,
        skills:        skills_training.keys.map { |sk| {sk.skill_name.for_json, sk.level(self)} }.to_h,
        ap:            @ap,
        max_ap:        MAX_AP,
        day:           @day,
        fame:          @fame,
        money:         @money,
        known_flora:   @known_flora.map(&.name.for_json),
        known_recipes: @known_recipes.map { |recipe| recipe.for_json },
        bag:           @bag.map { |k, v| {k.name.for_json, v} },
        actions:       @actions.map &.for_json,
      }
    end
  end
end
