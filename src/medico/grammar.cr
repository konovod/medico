
module Grammar

enum Gender
  He
  She
  It
  They
end

enum Case
  Nominative
  Genitive
  Dative
  Accusative
  Instrumental
  Prepositional
  Locative
end

enum Number
  Single
  Plural
end

class Noun
  @gender : Gender
  @case_data : Tuple(Array(String), Array(String))

  private def init_size
    #Gen
    #@case_data = Array.new()
  end

  def initialize(@gender, str)
    n = Case.values.size
    @case_data = {Array(String).new(n, str), Array(String).new(n, str)}
  end

  # def initialize(*, old : String)
  #   afixed
  #   @gender =
  # end

end

end
