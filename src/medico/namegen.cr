require "./data/names"
require "./globals"

class NameGen
getter history

getter first, second
@chances1: Array(FLOAT)
@chances2: Array(FLOAT)

private def itemchance(item)
  return f(1000) / item[:value]
end

def initialize(afirst, asecond)
  @first = Array(NamedTuple(name: Symbol, value: Int32)).new
  @first += afirst
  @second = Array(NamedTuple(name: Symbol, value: Int32)).new
  @second += asecond
  @chances1 = @first.map{|item|itemchance(item)}
  @chances2 = @second.map{|item|itemchance(item)}
  @history = Set(String).new
end

def next(random = DEF_RND)
  @history.clear if @history.size > 0.9*@first.size*@second.size
  result = {"",0}
  loop do
    it1 = weighted_sample(@first, @chances1, random)
    it2 = weighted_sample(@second, @chances2, random)
    str = s(it1[:name])+" "+s(it2[:name])
    next if @history.includes?(str)
    @history << str
    result = {str, it1[:value]+it2[:value]}
    break
  end
  result
end

end


$disease_names = NameGen.new(DIS_NAMES1, DIS_NAMES2)
$chemical_names = NameGen.new(CHEM_NAMES1, CHEM_NAMES2)
