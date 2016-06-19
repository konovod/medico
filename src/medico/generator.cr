

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
      @diseases_pool = Array(Disease).new
      @types = Array(Kind).new
    end


    def init_effects
      @types = [Kind::Sympthom]*BIO_CONSTS[:SympthomEff] +
              [Kind::Param]*BIO_CONSTS[:ParamEff] +
              [Kind::Bullet]*BIO_CONSTS[:BulletEff]


    end


    def random_effects (good : FLOAT, *, sys = nil, count = 1, random = Random::DEFAULT)
        #TODO optimize later
      result = Set(Effect)

      while result.size < count
        need_sign = random.rand < good ? Sign::Positive : Sign::Negative
        loop do
          typ = @types.sample(random)
          break if need_sign ==  Sign::Positive || (typ != Kind::Bullet)
        end
        classes = KINDS_MAP[typ]
        e = @effects_pool.select do |eff|
          classes.find(eff.class) && (eff.sign == Sign::Neutral || eff.sign == need_sign)
        end.sample
      end
    end


  end

end
