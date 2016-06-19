

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
      Param => [ChangeParam],
      Sympthom => [AddSympthomEffect, RemoveSympthomEffect],
      Bullet => [MagicBulletEffect]
    }

    getter effects_pool
    getter diseases_pool


    def initialize
      @effects_pool = Array(Effect).new
      @diseases_pool = Array(Disease).new(BIO_CONSTS[:NDiseases])
      BIO_CONSTS[:NDiseases].times do |i|
        @diseases_pool << Disease.new(0)
      end
      @types = Array(Kind).new
    end

    N_DELTA = 2
    MAX_DELTA = 0.6
    private def gen_adders(p : BioParam)
      delta = {(p.min - p.average)*MAX_DELTA / N_DELTA, (p.max - p.average)*MAX_DELTA / N_DELTA}
      result = [] of Fuzzy::FuzzySet
      (1..N_DELTA).each {|i| result << Fuzzy::Pike.new(delta[0]*i)} if p.average != p.min
      (1..N_DELTA).each {|i| result << Fuzzy::Pike.new(delta[1]*i)} if p.average != p.max
      result
    end

    def init_effects
      @types = [Kind::Sympthom]*BIO_CONSTS[:SympthomEff] +
              [Kind::Param]*BIO_CONSTS[:ParamEff] +
              [Kind::Bullet]*BIO_CONSTS[:BulletEff]

      ALL_SYMPTHOMS.each do|symp|
        @effects_pool<<AddSympthomEffect.new(symp)
        @effects_pool<<RemoveSympthomEffect.new(symp)
      end
      @diseases_pool.map {|dis| @effects_pool<<MagicBulletEffect.new(dis)}
      ALL_PARAMS.each do |param|
        gen_adders(param).each{|delta| @effects_pool<<ChangeParam.new(param, delta)}
      end
    end


    def random_effects (good : FLOAT, *, sys = nil, count = 1, random = Random::DEFAULT)
        #TODO optimize later
      result = Set(Effect)

      while count > 0
        need_sign = random.rand < good ? Sign::Positive : Sign::Negative
        loop do
          typ = @types.sample(random)
          break if need_sign ==  Sign::Positive || (typ != Kind::Bullet)
        end
        classes = KINDS_MAP[typ]
        e = @effects_pool.select do |eff|
          classes.find(eff.class) && (eff.sign == Sign::Neutral || eff.sign == need_sign)
        end.sample
        if !result.includes? e
          count -= 1
          result << e
        end
      end
      result.to_a
    end


  end

end
