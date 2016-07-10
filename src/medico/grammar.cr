module Grammar
  extend self
  enum Gender
    He
    She
    It
    They
  end
  N_GENDERS    = Gender.values.size
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

  def split_string(s, n)
    result = Array(String).new(n)
    (s.split(/[\{\}]/).in_groups_of(2, "").map do |pair|
      base = pair[0]
      suf = pair[1].split(",")
      case suf.size
      when 1
        [base]*n
      when n
        suf.map { |x| base + x }
      else
        raise "cant parse name #{s}, expected #{n} variations got #{suf.size}"
      end
    end).reduce([""]*n) do |acc, it|
      it.each_with_index { |x, i| acc[i] = acc[i] + x }
      acc
    end
  end

  class Noun
    getter gender : Gender
    getter case_data : Tuple(Array(String), Array(String))

    def initialize(@gender, str)
      @case_data = {Array(String).new(N_CASES, str), Array(String).new(N_CASES, str)}
    end

    def initialize(*, parse : String)
      initialize(Gender::It, "")
      regex = /([MWUN])(.*)/
      match = regex.match(parse)
      case match
      when nil
        base = parse
      else
        @gender = GENDER_NAMES[match[1]]
        base = match[2]
      end
      parts = Grammar.split_string(base, 2*N_CASES)
      @case_data = {parts[0...N_CASES], parts[N_CASES...2*N_CASES]}
    end

    def get(acase = Case::Nominative, number = Number::Single)
      @case_data[number.value][acase.value]
    end
  end

  class Adjective
    @case_data : Array(Array(String))

    def initialize(str)
      @case_data = Array(Array(String)).new
      N_GENDERS.times do
        arr = Array(String).new(N_CASES, str)
        @case_data << arr
      end
    end

    def initialize(*, parse : String)
      initialize("")
      parts = Grammar.split_string parse, N_GENDERS*N_CASES
      @case_data = parts.in_groups_of(N_CASES, "")
    end

    def get(gender : Gender, acase = Case::Nominative)
      @case_data[gender.value][acase.value]
    end

    def +(noun : Noun)
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
