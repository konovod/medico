require "./fuzzy"
require "./data/*"

module Biology
  extend self

  data_bioparams
  data_systems
  data_sympthoms

  class BioParam < Fuzzy::Param
    getter name : Symbol

    def desc
      s(@name)
    end

    def initialize(@name, min, average, max)
      super(f(min), f(average), f(max))
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
    getter name : Symbol
    getter damage : FLOAT
    getter danger : FLOAT
    getter system : Symbol

    def desc
      s(@name)
    end

    def initialize(@system, @name, adanger, adamage)
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

  def effector_dead(data : TEffectorData) : Bool
    data < 0
  end

  class SystemState
    getter params : ParamsBuffer
    getter sympthoms # TODO: cache sympthoms too?
    getter name : Symbol
    getter effectors

    def initialize(@name)
      @sympthoms = Hash(Sympthom, FLOAT).new
      @params = ParamsBuffer.new
      @effectors = Hash(Effector, TEffectorData).new
      ALL_SYMPTHOMS.select { |sy| sy.system == @name }.each { |sy| @sympthoms[sy] = f(0) }
    end

    def reset
      @params.reset_all
      @sympthoms.keys.each { |x| @sympthoms[x] = f(0) }
    end

    def process_tick(random = Random::DEFAULT)
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
      part1 = (@params.get.sum{|param, value| param.damage(value.real)}) / N_PARAMS
      part2 = @sympthoms.select{|sym, val| val > 0}.sum{|sym, val| sym.damage}
      part1+part2
    end

    def danger
      @sympthoms.select{|sym, val| val > 0}.sum{|sym, val| sym.danger}
    end

  end

  class Patient
    getter name : String
    getter systems
    property maxhealth : FLOAT
    getter immunity : FLOAT = f(1)

    def initialize(@name,random = Random::DEFAULT)
      @maxhealth = f(2+random.rand*8) #TODO gauss distribution
      @health = @maxhealth
      @systems = Hash(Symbol, SystemState).new
      ALL_SYSTEMS.each { |sys| @systems[sys] = SystemState.new(sys) }
      check_immunity
    end

    private def check_immunity
      imm = [f(0.5), @health/@maxhealth].max
      imm = @systems.values.reduce(imm) do |mul, sys|
        dam = sys.damage
        dam > 0.5 ? mul*dam : mul
      end
      @immunity = imm
    end

    private def check_health
      hp_dam = -BIO_CONSTS[:HealthDump] + @systems.values.sum(&.danger)
      @health -= hp_dam if hp_dam > 0
      @health += BIO_CONSTS[:HealthRegen] if @health < @maxhealth
    end


    def reset
      @systems.values.each(&.reset)
      check_immunity
    end

    def process_tick(random = Random::DEFAULT)
      @systems.values.each { |sys| sys.process_tick(random) }
      check_immunity
      check_health
    end
  end

  BIO_RATER = Hash(BioParam, Fuzzy::RateSet).zip(
    ALL_PARAMS.to_a,
    ALL_PARAMS.to_a.map { |x| Fuzzy::RateSet.new(x, 1) }
  )

  abstract class Effect
    abstract def apply(sys : SystemState, power : FLOAT)
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
