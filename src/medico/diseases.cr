require "./biology"

module Biology

  class Disease
    def first : DiseaseStage
      @first.as(DiseaseStage)
    end

    getter systems : Set(Symbol)

    def initialize(power : Int32)
      @systems = ALL_SYSTEMS.to_set
      @first = DiseaseStage.new(self, power)
    end


    def generate(univ : Universe, random = Random::DEFAULT)
      #TODO names generator
      #systems
      n = random.rand(ALL_SYSTEMS.size)+2
      arr = [] of Symbol
      n.times { arr<<ALL_SYSTEMS.to_a.sample(random) }
      @systems = arr.to_set
      #stages
      
    end


    def process(patient : Patient, state : DiseaseState, random = Random::DEFAULT) : Bool
      # TODO save antigenes after cure
      state.antigene += 0.3

      return patient.systems.values.any? { |sys| sys.effectors.has_key?(state.stage) }
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
      @next_stage = power > 0 ? DiseaseStage.new(@disease, power - 1) : nil
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
