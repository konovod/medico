require "./biology.cr"
require "./effectors.cr"
require "./substances.cr"

module Biology
  class Universe
    enum Kind
      Param
      Sympthom
      Bullet
    end
    KINDS_MAP = {
      Kind::Param    => [ChangeParam],
      Kind::Sympthom => [AddSympthomEffect, RemoveSympthomEffect],
      Kind::Bullet   => [MagicBulletEffect],
    }

    getter effects_pool
    getter diseases_pool
    getter param_rules
    getter flora
    getter reactions
    getter recipes
    getter chemicals
    getter substances
    getter reactions_generated
    getter substance_combinations
    getter recipes_limit
    getter disease_names
    getter chemical_names
    alias TRecipeTuple = Union(Tuple(Substance, Substance), Tuple(Substance, Substance, Substance), Tuple(Substance, Substance, Substance, Substance))

    def initialize
      @disease_names = NameGen.new(DIS_NAMES1, DIS_NAMES2)
      @chemical_names = NameGen.new(CHEM_NAMES1, CHEM_NAMES2)

      @effects_pool = Array(Effect).new
      @diseases_pool = Array(Disease).new(CONFIG[:NDiseases])
      CONFIG[:NDiseases].times do |i|
        @diseases_pool << Disease.new
      end
      @types = Array(Kind).new
      @param_rules = Array(ParamRule).new
      @flora = Array(Substance).new(FLORA_NAMES.size)
      FLORA_NAMES.each_with_index { |item, i| @flora << Substance.new(i, 1, s(item[:name]), item[:value]) }
      @reactions = Array(ReactionRule).new
      @reactions_generated = Set(Tuple(Substance, Substance)).new
      @chemicals = Array(Substance).new
      @substances = Array(Substance).new
      @substances.concat @flora
      @recipes = Array(Alchemy::Recipe).new
      @substance_combinations = Set(TRecipeTuple).new
      @recipes_limit = Hash(Substance, Int32).new(0)
    end

    def generate(random = DEF_RND)
      Log.info { "initializing effects" }
      init_effects
      Log.info { "initializing param rules" }
      init_param_rules(random)
      Log.info { "initializing diseases" }
      init_diseases(random)
      Log.info { "initializing flora" }
      generate_flora(random)
    end

    MAX_DELTA = 0.6

    private def gen_adders(p : BioParam)
      delta = {(p.min - p.average)*MAX_DELTA / PARAM_DELTA_STAGES, (p.max - p.average)*MAX_DELTA / PARAM_DELTA_STAGES}
      result = [] of Fuzzy::FuzzySet
      result.concat((1..PARAM_DELTA_STAGES).map { |i| Fuzzy::Pike.new(delta[0]*i) }) if p.average != p.min
      result.concat((1..PARAM_DELTA_STAGES).map { |i| Fuzzy::Pike.new(delta[1]*i) }) if p.average != p.max
      result
    end

    def init_effects
      @types = [Kind::Sympthom]*CONFIG[:SympthomEff] +
               [Kind::Param]*CONFIG[:ParamEff] +
               [Kind::Bullet]*CONFIG[:BulletEff]
      @effects_pool.clear
      @effects_pool.concat ALL_SYMPTHOMS.map { |symp| AddSympthomEffect.new(symp) }
      @effects_pool.concat ALL_SYMPTHOMS.map { |symp| RemoveSympthomEffect.new(symp) }
      @effects_pool.concat @diseases_pool.map { |dis| MagicBulletEffect.new(dis) }
      ALL_PARAMS.each do |param|
        @effects_pool.concat gen_adders(param).map { |delta| ChangeParam.new(param, delta) }
      end
    end

    def random_effects_sys(good : FLOAT, sys : Enumerable(System), count = 1, random = DEF_RND)
      random_effects(good, count: count, random: random) do |eff|
        (!eff.is_a?(RemoveSympthomEffect) || sys.includes?(eff.as(RemoveSympthomEffect).sympthom.system)) &&
          (!eff.is_a?(AddSympthomEffect) || sys.includes?(eff.as(AddSympthomEffect).sympthom.system))
      end
    end

    def random_effects_any(good : FLOAT, count = 1, random = DEF_RND)
      random_effects(good, count: count, random: random) do |eff|
        true
      end
    end

    def random_effects(good : FLOAT, *, count = 1, random = DEF_RND)
      # TODO optimize later
      result = Set(Effect).new
      count.times do
        need_sign = random.rand < good ? Sign::Positive : Sign::Negative
        loop do
          typ = @types.sample(random)
          next if need_sign == Sign::Negative && (typ == Kind::Bullet)
          classes = KINDS_MAP[typ]
          elist = @effects_pool.select do |eff|
            classes.includes?(eff.class) &&
              (eff.sign == Sign::Neutral || eff.sign == need_sign) && yield(eff)
          end
          next if elist.empty?
          e = elist.sample(random)
          next if result.includes? e
          result << e
          break
        end
      end
      result.to_a
    end

    def init_diseases(random = DEF_RND)
      @diseases_pool.each { |dis| dis.generate(self, random) }
    end

    def init_param_rules(random = DEF_RND)
      # gen rules for each variation
      ALL_PARAMS.each do |param|
        @param_rules.concat(BIO_RATER[param].items.select { |checker|
          checker.is_a?(Fuzzy::Trapezoid) && checker.rate(param.average) <= 0
        }.map { |delta|
          ParamRule.new(param, delta)
        })
      end
      # add effects
      CONFIG[:NRules].times do
        rule = @param_rules.weighted_sample(random) { |p| p.param.damage(p.checker.average) }
        rule.effects.concat(random_effects(0.1, count: 1, random: random) do |eff|
          case eff
          when ChangeParam
            eff.param != rule.param && !(eff.param.is_a? LiquidParam) && (rule.param.is_a? LiquidParam)
          else
            true
          end
        end)
      end
      # remove empty rules
      @param_rules.reject! { |rule| rule.effects.empty? }
    end

    private def make_recipe_tuple(arr) : TRecipeTuple
      case arr.size
      when 2
        return {arr[0], arr[1]}
      when 3
        return {arr[0], arr[1], arr[2]}
      when 4
        return {arr[0], arr[1], arr[2], arr[3]}
      else
        raise "make_recipe_tuple: incorrect size #{arr.size}"
      end
    end

    private def try_recipe(combination : TRecipeTuple, random = DEF_RND)
      return if @substance_combinations.includes?(combination)
      @substance_combinations << combination
      # TODO optimize each_combination, lol
      return unless combination.sorted_by?(&.order)
      return if combination.any? { |subs| @recipes_limit[subs] >= CONFIG[:RecipesLimiter] }
      counter_chance = 1 + combination.sum { |subs| subs.complexity - 1 }
      return if random.rand > CONFIG[:RecipeChance] / counter_chance / counter_chance
      combination.each { |subs| @recipes_limit[subs] += 1 }
      complexity = 1 + combination.map(&.complexity).max
      name, power = @chemical_names.next(false, random)
      power += complexity
      subs = (@chemicals.find { |it| it.name == name }) ||
             Substance.new(@substances.size - 1, complexity, name, power).generate(self, random)
      recipe = Alchemy::Recipe.new(subs.as(Substance))
      combination.each do |ingridient|
        recipe.substances[ingridient] = random.rand(5) + 1
      end
      @chemicals << subs
      @substances << subs
      @recipes << recipe
    end

    def generate_recipes(base : Array(Substance), added : Substance, random = DEF_RND)
      # p "generating for #{added.name} @ #{base.size}, already - #{@recipes.size}"
      (1...CONFIG[:MaxRecipeSize]).each do |i|
        each_combination(i, base) do |combo|
          arr = combo.to_a
          arr << added
          try_recipe(make_recipe_tuple(arr), random)
        end
      end
    end

    def init_substances(stash : Array(Substance), random = DEF_RND)
      return if stash.empty?
      aset = stash.dup
      base = [aset.pop]
      while !aset.empty?
        next_elem = aset.pop
        generate_recipes(base, next_elem, random)
        base << next_elem
      end
    end

    def reset_recipes
      @chemicals.clear
      @recipes.clear
      @substances.clear
      @substance_combinations.clear
      @recipes_limit.clear
      @substances.concat @flora
    end

    def generate_flora(random = DEF_RND)
      @flora.each &.generate(self, random)
    end

    def init_reactions(stash : Array(Substance), random = DEF_RND)
      stash.each do |s1|
        stash.reverse.each do |s2|
          break if s1 == s2
          next unless s1.systems.intersects? s2.systems
          list = [s1, s2].sort_by(&.order)
          tuple = {list[0], list[1]}
          next if @reactions_generated.includes?(tuple)
          @reactions_generated << tuple
          next unless random.rand < CONFIG[:ReactionChance]
          react = ReactionRule.new
          react.substances.concat list
          react.effects.concat random_effects_sys(0.5, s1.systems & s2.systems, count: 1, random: random)
          list.each { |subs| subs.reactions << react }
        end
      end
    end

    def generate_infection(patient : Patient, random = DEF_RND)
      loop do
        patient.reset
        dis = diseases_pool.sample(random)
        patient.infect(dis, random)
        time = CONFIG[:PatientSimulation] + random.rand(CONFIG[:PatientSimulation])
        felt_bad = false
        time.times do
          patient.process_tick(random)
          break if patient.dead || patient.diseases.empty?
          felt_bad |= !patient.feels_good
        end
        break if felt_bad && !patient.dead && !patient.diseases.empty?
      end
    end
  end
end
