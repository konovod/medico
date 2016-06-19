require "./biology"

module Biology

  class AddSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] += power
    end

    def sign
      Sign::Negative
    end
  end

  class RemoveSympthomEffect < Effect
    getter sympthom : Sympthom

    def initialize(@sympthom)
    end

    def apply(sys : SystemState, power : FLOAT)
      sys.sympthoms[@sympthom] -= power
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
      sys.effectors[state.stage] = v-(power*50).to_i
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
        delta = @param.max-curval
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

    def process(**context) : TEffectorData
      newstate = checker.incremental(
        context[:state].params.get(Index::OLD)[@param].real,
        context[:state].params.get(Index::PREV)[@param].real,
        context[:data] > 0,
        context[:random])
      apply(context) if newstate
      return (newstate ? 1 : 0)
    end
    def sign
      Sign::Neutral
    end

  end

  CRUNCH = DiseaseStage.new(Disease.new(1), 0)

  class Disease
    def first : DiseaseStage
      @first.as(DiseaseStage)
    end
    getter systems : Set(Symbol)

    def initialize(power : Int32)
      #TODO proper generation
      @systems = ALL_SYSTEMS.to_set
      @first = DiseaseStage.new(self, power)
    end

    def process(patient : Patient, state : DiseaseState, random = Random::DEFAULT) : Bool
      #TODO save antigenes after cure
      state.antigene += 0.3

      return patient.systems.values.any? {|sys| sys.effectors.has_key?(state.stage)}
    end

  end

  class DiseaseState
    property antigene : FLOAT
    property stage : DiseaseStage

    def initialize(dis : Disease)
      @antigene = f(0.05)
      @stage = dis.first
    end

  end

  class DiseaseStage < Effector
    getter disease : Disease
    getter next_stage
    getter speed : FLOAT


    def initialize(@disease, power)
      super()
      @speed = f(power)
      @next_stage = power > 0 ? DiseaseStage.new(@disease, power-1) : nil
    end

    def process(**context) : TEffectorData
      apply(context)
      v = context[:data]
      sys = context[:state]
      pat = sys.owner
      if context[:random].rand * speed * sys.damage > pat.immunity + pat.diseases[@disease].antigene
        v += 10
      else
        v -= 10
      end
      if v > 100
        pat.spread(@disease)
        v = 50
      end
      return v
    end

  end


end
