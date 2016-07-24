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
      SYSTEM_NAMES[self.value].get(*args)
    end
  end

  SYSTEM_NAMES = {
    :Circulatory,
    :Digestion,
    :Joints,
    :Lungs,
    :Brains,
    :LOR,
  }.map { |sym| s(sym) }
end
