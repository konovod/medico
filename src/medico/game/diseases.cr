require "./biology"
require "./namegen"

module Biology
  class Disease
    def first : DiseaseStage
      @first.as(DiseaseStage)
    end

    getter systems : Set(System)
    getter name
    getter danger

    def initialize
      @name = Grammar::Noun.new(parse: "")
      @danger = 0
      @systems = System.values.to_set
      @first = DiseaseStage.new(self, 1, f(1))
    end

    def to_s(io)
      io << @name
    end

    def generate(univ : Universe, random = DEF_RND)
      # systems
      n = random.rand(System.values.size + 1) + 2
      arr = [] of System
      n.times { arr << System.values.sample(random) }
      @systems = arr.to_set
      # stages
      @name, @danger = univ.disease_names.next(true, random)
      nstages = random.rand(CONFIG[:MaxStages] - 1) + 2
      curstage = nil
      nstages.times do |i|
        astage = DiseaseStage.new(self, i + 1, f(@danger*(nstages - i + 4)*CONFIG[:DisDanger]))
        if i == 0
          @first = astage
        else
          curstage.as(DiseaseStage).next_stage = astage
          astage.effects.concat(curstage.as(DiseaseStage).effects)
        end
        curstage = astage
        curstage.effects.concat(univ.random_effects_sys(f(0), sys: @systems, random: random, count: 2*CONFIG[:DisRules] / 5))
        curstage.effects.uniq! # if i > 0
        # curstage

      end
    end

    def process(patient : Patient, state : DiseaseState, random = DEF_RND) : Bool
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
    getter index : Int32

    def initialize(@disease, @index, @speed)
      super()
      @next_stage = nil
    end

    def to_s(io)
      io << "#{@disease}-#{@index}"
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
        pat.spread(@disease, context[:random])
        v = 50
      end
      return v
    end
  end
end
