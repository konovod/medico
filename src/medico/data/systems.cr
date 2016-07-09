require "../grammar.cr"

module Biology
  enum System
    Circulatory
    Digestion
    Joints
    Lungs
    Brains
    LOR

    def name(*args)
      SYSTEM_NAMES[self.value].to_s(*args)
    end
  end

  SYSTEM_NAMES = {
    :Circulatory,
    :Digestion,
    :Joints,
    :Lungs,
    :Brains,
    :LOR,
  }.map{|sym| Grammar::Noun.new(parse: s(sym)) }

end
