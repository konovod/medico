require "./biology.cr"
require "./effectors.cr"

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

    def initialize
      @effects_pool = Array(Effect).new
      @diseases_pool = Array(Disease).new(BIO_CONSTS[:NDiseases])
      BIO_CONSTS[:NDiseases].times do |i|
        @diseases_pool << Disease.new
      end
      @types = Array(Kind).new
      @param_rules = Array(ParamRule).new
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
      @types = [Kind::Sympthom]*BIO_CONSTS[:SympthomEff] +
        [Kind::Param]*BIO_CONSTS[:ParamEff] +
        [Kind::Bullet]*BIO_CONSTS[:BulletEff]
      @effects_pool.clear
      @effects_pool.concat ALL_SYMPTHOMS.map { |symp| AddSympthomEffect.new(symp) }
      @effects_pool.concat ALL_SYMPTHOMS.map { |symp| RemoveSympthomEffect.new(symp) }
      @effects_pool.concat @diseases_pool.map { |dis| MagicBulletEffect.new(dis) }
      ALL_PARAMS.each do |param|
        @effects_pool.concat gen_adders(param).map { |delta| ChangeParam.new(param, delta) }
      end
    end

    def random_effects_sys(good : FLOAT, sys, count = 1, random = DEF_RND)
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

    def random_effects(good : FLOAT, *, sys = ALL_SYSTEMS.to_set, count = 1, random = DEF_RND)
      # TODO optimize later
      result = Set(Effect).new

      while count > 0
        need_sign = random.rand < good ? Sign::Positive : Sign::Negative
        typ = @types.sample(random)
        while need_sign == Sign::Negative && (typ == Kind::Bullet)
          typ = @types.sample(random)
        end
        classes = KINDS_MAP[typ]
        e = @effects_pool.select do |eff|
          classes.includes?(eff.class) &&
            (eff.sign == Sign::Neutral || eff.sign == need_sign) && yield(eff)
        end.sample(random)
        if !result.includes? e
          count -= 1
          result << e
        end
      end
      result.to_a
    end

    def init_diseases(random = DEF_RND)
      @diseases_pool.each { |dis| dis.generate(self, random) }
    end

    def init_param_rules(random = DEF_RND)
      ALL_PARAMS.each do |param|
        @param_rules.concat(BIO_RATER[param].items.select{ |checker|
          checker.is_a?(Fuzzy::Trapezoid) && checker.rate(param.average) <= 0
        }.map { |delta|
          ParamRule.new(param, delta)
        })
      end
    end
  end
end
