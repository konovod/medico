require "./data/names"
require "./globals"
require "./grammar"

class NameGen
  getter history

  getter first, second
  @chances1 : Array(FLOAT)
  @chances2 : Array(FLOAT)

  private def itemchance(item)
    return f(1000) / item[:value]
  end

  def initialize(afirst, asecond)
    @first = Array(NamedTuple(name: Symbol, value: Int32)).new
    @first += afirst
    @second = Array(NamedTuple(name: Symbol, value: Int32)).new
    @second += asecond
    @chances1 = @first.map { |item| itemchance(item) }
    @chances2 = @second.map { |item| itemchance(item) }
    @history = Set(Tuple(Symbol, Symbol)).new
  end

  def next(unique : Bool, random = DEF_RND)
    raise("too many names #{@history.size}, max=#{@first.size*@second.size}") if unique && @history.size > 0.9*@first.size*@second.size
    #result = {"", 0}
    loop do
      it1 = weighted_sample(@first, @chances1, random)
      it2 = weighted_sample(@second, @chances2, random)
      if unique
        tuple = {it1[:name], it2[:name]}
        next if @history.includes?(tuple)
        @history << tuple
      end
      str = s(it1[:name], Grammar::Adjective) + s(it2[:name])
      result = {str, it1[:value] + it2[:value]}
      break result
    end
  end
end

$disease_names = NameGen.new(DIS_NAMES1, DIS_NAMES2)
$chemical_names = NameGen.new(CHEM_NAMES1, CHEM_NAMES2)
