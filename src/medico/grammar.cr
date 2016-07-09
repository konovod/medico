module Grammar
  enum Gender
    He
    She
    It
    They
  end
  GENDER_NAMES = {"W" => Gender::She, "M" => Gender::He, "U" => Gender::It, "N" => Gender::They}

  enum Case
    Nominative
    Genitive
    Dative
    Accusative
    Instrumental
    Prepositional
    Locative
  end
  N_CASES = Case.values.size

  enum Number
    Single
    Plural
  end

  class Noun
    getter gender : Gender
    @case_data : Tuple(Array(String), Array(String))

    def initialize(@gender, str)
      @case_data = {Array(String).new(N_CASES, str), Array(String).new(N_CASES, str)}
    end

    def initialize(*, parse : String)
      initialize(Gender::It, "")
      regex = /(.)(.*)\{(.*)\}/
      match = regex.match(parse)
      case match
      when nil
        initialize(Gender::It, parse)
        return
      else
        agender = GENDER_NAMES[match[1]]?
        if agender
          base = match[2]
          @gender = agender
        else
          base = match[1] + match[2]
          @gender = Gender::He
        end
        parts = match[3].split ","
        raise "cant parse case data" if parts.size < 2*N_CASES
        @case_data = {parts[0...N_CASES].map { |s| base + s }, parts[N_CASES...2*N_CASES].map { |s| base + s }}
      end
    end

    def to_s(acase = Case::Nominative, number = Number::Single)
      @case_data[number.to_i][acase.to_i]
    end
  end
end
