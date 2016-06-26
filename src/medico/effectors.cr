require "./biology"
require "./diseases"

module Biology
  class AddSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] += power if sys.sympthoms.has_key? @sympthom
    end

    def sign
      Sign::Negative
    end
  end

  class DummyEffect < Effect
    def apply(sys : SystemState, power : FLOAT)
    end
    def sign
      Sign::Neutral
    end
  end

  DUMMY_EFFECT = DummyEffect.new


  class RemoveSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] -= power if sys.sympthoms.has_key? @sympthom
    end

    def sign
      Sign::Positive
    end
  end

  class MagicBulletEffect < Effect
    getter disease : Disease

    def initialize(@disease)
    end

    def apply(sys : SystemState, power : FLOAT)
      state = sys.owner.diseases[@disease]?
      return unless state
      v = sys.effectors[state.stage]?
      return unless v
      sys.effectors[state.stage] = v - (power*50).to_i
    end

    def sign
      Sign::Positive
    end
  end

  class ChangeParam < Effect
    getter param : BioParam
    getter changer : Fuzzy::FuzzySet

    def initialize(@param, @changer)
    end

    def apply(sys : SystemState, power : FLOAT)
      delta = changer.average * power
      curval = sys.params.get(Index::CUR)[@param].real
      if curval + delta > @param.max
        delta = @param.max - curval
      elsif curval + delta < @param.min
        delta = @param.min - curval
      end
      sys.params.get(Index::CUR)[@param].real += delta
      ALL_PARAMS.each do |p|
        next if p == @param
        sys.params.get(Index::CUR)[p].real -= delta/N_LIQUIDS
      end if @param.class == LiquidParam
    end

    def sign
      Sign::Neutral
    end
  end

  class TimedEffector < Effector
    def process(**context) : TEffectorData
      apply(context)
      return context[:data] - 1
    end
  end

  class ParamRule < Effector
    # TODO: maybe complex rules?
    getter param : BioParam
    getter checker : Fuzzy::FuzzySet

    def initialize(@param, @checker)
      super()
    end

    def to_s(io)
      io<<"(#{@param.desc} is #{@checker.average})"
    end

    def process(**context) : TEffectorData
      newstate = checker.incremental(
        context[:state].params.get(Index::OLD)[@param].real,
        context[:state].params.get(Index::PREV)[@param].real,
        context[:data] > 0,
        context[:random])

        if $verbose
          oldval = context[:state].params.get(Index::OLD)[@param].real
          newval = context[:state].params.get(Index::PREV)[@param].real
          oldstate = context[:data] > 0
          logs("triggered #{self} at #{oldval}->#{newval}") if newstate && !oldstate
          logs("disabled #{self} at #{oldval}->#{newval}") if !newstate && oldstate
          logs("continue #{self} at #{oldval}->#{newval}") if newstate && oldstate

        end

      apply(context) if newstate
      return (newstate ? 1 : 0)
    end
  end
end
