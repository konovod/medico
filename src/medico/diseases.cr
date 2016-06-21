require "./biology"

module Biology

  class Disease
    def first : DiseaseStage
      @first.as(DiseaseStage)
    end

    getter systems : Set(Symbol)

    def initialize
      @systems = ALL_SYSTEMS.to_set
      @first = DiseaseStage.new(self, f(1))
    end

    def to_s(io)
      io << "disease(#{@systems})"
    end

    def generate(univ : Universe, random = Random::DEFAULT)
      #TODO names generator
      #systems
      n = random.rand(ALL_SYSTEMS.size+1)+2
      arr = [] of Symbol
      n.times { arr<<ALL_SYSTEMS.to_a.sample(random) }
      @systems = arr.to_set
      #stages
      #TODO - danger generation (was in namegen)
      danger = 5+random.rand(10)
      nstages = random.rand(BIO_CONSTS[:MaxStages]-1)+2
      curstage = nil
      nstages.times do |i|
        astage = DiseaseStage.new(self, f(danger*(nstages - i + 4)*BIO_CONSTS[:DisDanger]))
        if i==0
          @first = astage
        else
          curstage.as(DiseaseStage).next_stage = astage
          astage.effects.concat(curstage.as(DiseaseStage).effects)
        end
        curstage = astage
        curstage.effects.concat(univ.random_effects(f(0), sys: @systems, random: random, count: 2*BIO_CONSTS[:DisRules] / 5))
        curstage.effects.uniq! #if i > 0
        #curstage

      end

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
    property next_stage : DiseaseStage?
    getter speed : FLOAT

    def initialize(@disease, @speed)
      super()
      @next_stage = nil
    end

    def to_s(io)
      io << "#{@disease}.#{@effects.size}"
    end

    def process(**context) : TEffectorData
      apply(context)
      v = context[:data]
      sys = context[:state]
      pat = sys.owner
      raise "pat healed?" unless pat.diseases[@disease]?
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
