require "./biology"

module Biology

  class AddSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] += power
    end
  end

  class RemoveSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] -= power
    end
  end

  class ChangeParam < Effect
    getter param : BioParam
    getter changer : Fuzzy::FuzzySet

    def initialize(@param, @changer)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.params.get(Index::CUR)[@param].real += changer.average * power
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

    def process(**context) : TEffectorData
      newstate = checker.incremental(
        context[:state].params.get(Index::OLD)[@param].real,
        context[:state].params.get(Index::PREV)[@param].real,
        context[:data] > 0,
        context[:random])
      apply(context) if newstate
      return (newstate ? 1 : 0)
    end
  end
end
