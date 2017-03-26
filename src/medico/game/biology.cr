require "./fuzzy"
require "./grammar"
require "./social"
require "./data/*"

module Biology
  extend self

  class BioParam < Fuzzy::Param
    getter name : Grammar::Noun

    def initialize(aname, min, average, max)
      super(f(min), f(average), f(max))
      @name = s(aname)
    end

    def damage(value)
      return 0 if value == @average
      if value < @average
        @average == @min ? 0 : (@average - value) / (@average - @min)
      else
        @average == @max ? 0 : (value - @average) / (@max - @average)
      end
    end
  end

  class LiquidParam < BioParam
    def initialize(name)
      super(name, f(0), f(1) / N_LIQUIDS, f(1))
    end
  end

  class Sympthom
    getter name : Grammar::Noun
    getter damage : FLOAT
    getter danger : FLOAT
    getter system : System

    def initialize(@system, aname, adanger, adamage)
      @name = s(aname)
      @damage = f(adamage)
      @danger = f(adanger)
    end
  end

  enum Index
    CUR  = 0
    OLD  = 1
    PREV = 2
  end
  alias TParams = Hash(BioParam, Fuzzy::ParamValue)

  class ParamsBuffer
    def initialize
      @data = {TParams.new, TParams.new, TParams.new}
      3.times do |i|
        ALL_PARAMS.each do |p|
          @data[i][p] = Fuzzy::ParamValue.new(p)
        end
      end
      @index = 0
      reset_all
    end

    def reset_all
      reset(Index::CUR)
      reset(Index::OLD)
      reset(Index::PREV)
    end

    def reset(n)
      get(n).values.each { |x| x.real = x.owner.average }
    end

    def get(n : Index = Index::CUR)
      @data[(@index + n.value) % 3]
    end

    def scroll
      @index = (@index + 1) % 3
      reset(Index::CUR)
    end
  end

  alias TEffectorData = Int32

  class SystemState
    getter params : ParamsBuffer
    getter sympthoms # TODO: cache sympthoms too?
    getter effectors
    getter sys : System
    getter owner : Patient

    def to_s(io)
      io << "#{sys.name} #{owner.name.get(Grammar::Case::Genitive)}"
    end

    def initialize(@owner, @sys)
      @sympthoms = Hash(Sympthom, FLOAT).new
      @params = ParamsBuffer.new
      @effectors = Hash(Effector, TEffectorData).new
      ALL_SYMPTHOMS.select { |sy| sy.system == @sys }.each { |sy| @sympthoms[sy] = f(0) }
    end

    def reset
      @params.reset_all
      @sympthoms.keys.each { |x| @sympthoms[x] = f(0) }
      @effectors.select! { |k, v| k.is_a? ParamRule }
      @effectors.each_key { |k| @effectors[k] = 0 }
    end

    private def effector_dead(data : TEffectorData) : Bool
      data < 0
    end

    def process_tick(random = DEF_RND)
      @params.scroll
      @sympthoms.keys.each { |x| @sympthoms[x] = f(0) }
      # apply effectors
      @effectors.each do |eff, data|
        @effectors[eff] = eff.process(state: self, data: data, random: random)
      end
      # remove inactive effectors
      @effectors.reject! do |eff, data|
        effector_dead(data)
      end
    end

    def damage
      part1 = (@params.get.sum { |param, value| param.damage(value.real) }) / N_PARAMS
      part2 = @sympthoms.select { |sym, val| val > 0 }.sum { |sym, val| sym.damage }
      part1 + part2
    end

    def danger
      @sympthoms.select { |sym, val| val > 0 }.sum { |sym, val| sym.danger }
    end

    def infect(stage : DiseaseStage)
      # Log.s "#{self} infected with #{stage}"
      oldlevel = @effectors[stage]?
      return if oldlevel && oldlevel > 50
      @effectors[stage] = 50
    end
  end

  class Patient
    getter name : Grammar::Noun
    getter status : Social::Status
    getter systems
    property maxhealth : FLOAT
    property starting_health : FLOAT
    property health : FLOAT
    getter immunity : FLOAT = f(1)
    getter diseases

    def to_s(io)
      io << name.to_s
    end

    def initialize(random = DEF_RND)
      initialize(random, status: Social.gen_status(random))
    end

    def initialize(random = DEF_RND, *, status)
      @status = status
      @name = @status.name + s(Social::HUMAN_NAMES.to_a.sample(random))
      @maxhealth = f(randg(10, 3, random).clamp(2, 25))
      @health = @maxhealth
      @starting_health = health
      @diseases = Hash(Disease, DiseaseState).new
      @systems = Hash(System, SystemState).new
      System.values.each { |sys| @systems[sys] = SystemState.new(self, sys) }
      check_immunity
    end

    def feels_good
      @health >= @maxhealth
    end

    def is_good
      feels_good && @diseases.empty?
    end

    def dead
      @health <= 0
    end

    private def check_immunity
      imm = {f(0.5), @health/@maxhealth}.max
      imm = @systems.values.reduce(imm) do |mul, sys|
        dam = sys.damage
        dam > 0.5 ? mul*dam : mul
      end
      @immunity = imm
    end

    private def check_health
      unless dead
        hp_dam = -CONFIG[:HealthDump] + @systems.values.sum(&.danger)
        @health -= hp_dam if hp_dam > 0
        @health += CONFIG[:HealthRegen] if @health < @maxhealth
      end
    end

    def reset
      @systems.values.each(&.reset)
      @health = @maxhealth
      @diseases.clear
      check_immunity
    end

    def process_tick(random = DEF_RND)
      @systems.values.each { |sys| sys.process_tick(random) }
      check_immunity
      check_health
      remove_dis = @diseases.select { |dis, state| !dis.process(self, state, random) }
      remove_dis.each { |dis, x| healed dis }
    end

    def healed(dis : Disease)
      # Log.s "#{self} healed of #{dis}"
      state = @diseases[dis]?
      return unless state
      stage = state.stage
      @diseases.delete(dis)
      @systems.values.each do |sys|
        sys.effectors.delete(stage)
      end
    end

    def infect(dis : Disease, random = DEF_RND)
      return if @diseases.has_key?(dis)
      # Log.s "#{self} infected with #{dis}"
      @diseases[dis] = DiseaseState.new(dis)
      @systems[dis.systems.to_a.sample(random)].infect(dis.first)
    end

    def spread(dis : Disease, random = DEF_RND)
      # Log.s "in #{self} spreaded #{dis}"
      state = @diseases[dis]?
      return unless state
      oldstage = state.stage
      if random.rand < 0.5
        @systems[dis.systems.to_a.sample(random)].infect(oldstage)
      else
        newstage = oldstage.next_stage
        return unless newstage
        # Log.s "it progresses!"
        state.stage = newstage
        @systems.values.each do |sys|
          sys.effectors.delete(oldstage)
          sys.effectors[newstage] = 50
        end
      end
    end
  end

  BIO_RATER = Hash(BioParam, Fuzzy::RateSet).zip(
    ALL_PARAMS.to_a,
    ALL_PARAMS.to_a.map { |x| Fuzzy::RateSet.new(x, PARAM_RATE_STAGES - 1) }
  )

  enum Sign
    Negative
    Neutral
    Positive
  end

  abstract class Effect
    abstract def apply(sys : SystemState, power : FLOAT)
    abstract def sign : Sign # TODO make it class const?
  end

  abstract class Effector
    getter effects

    alias Context = NamedTuple(state: SystemState, data: TEffectorData, random: Random::MT19937)

    abstract def process(**context) : TEffectorData

    def calc_power(context : Context) : FLOAT
      f(1)
    end

    def apply(context : Context)
      @effects.each { |eff| eff.apply(context[:state], calc_power(context)) }
    end

    def initialize
      @effects = Array(Effect).new
    end
  end
end
