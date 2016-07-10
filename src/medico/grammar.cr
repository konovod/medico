module Grammar
  extend self
  enum Gender
    He
    She
    It
    They
  end
  N_GENDERS = Gender.values.size
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
    getter case_data : Tuple(Array(String), Array(String))

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
        raise "cant parse case data: #{parse}" if parts.size < 2*N_CASES
        @case_data = {parts[0...N_CASES].map { |s| base + s }, parts[N_CASES...2*N_CASES].map { |s| base + s }}
      end
    end

    def get(acase = Case::Nominative, number = Number::Single)
      @case_data[number.value][acase.value]
    end

  end

  class Adjective
    @case_data : Array(Array(String))

    def initialize(str)
      @case_data =Array(Array(String)).new
      N_GENDERS.times do
        arr = Array(String).new(N_CASES, str)
        @case_data << arr
      end
    end

    def initialize(*, parse : String)
      regex = /(.*)\{(.*)\}/
      match = regex.match(parse)
      case match
      when nil
        initialize(parse)
        return
      else
        base = match[1]
        initialize(base)
        parts = match[2].split ","
        raise "cant parse case data: #{parse}" if parts.size < N_GENDERS*N_CASES
        parts.reverse!
        N_GENDERS.times do |i|
          N_CASES.times do |j|
            @case_data[i][j] += parts.pop
          end
        end
      end
    end

    def get(gender : Gender, acase = Case::Nominative)
      @case_data[gender.value][acase.value]
    end

    def + (noun : Noun)
      result = Noun.new(noun.gender, "")
      [noun.gender, Gender::They].each_with_index do |g, i|
        Case.values.each_with_index do |c, j|
          result.case_data[i][j] = "#{get(g, c)} #{noun.get(c, Number.values[i])}"
        end
      end
      result
    end
  end

end
