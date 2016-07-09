module Biology
  enum System
    Circulatory
    Digestion
    Joints
    Lungs
    Brains
    LOR

    def name
      SYSTEM_NAMES[self.value]
    end
  end

  SYSTEM_NAMES = {
    :Circulatory,
    :Digestion,
    :Joints,
    :Lungs,
    :Brains,
    :LOR,
  }
end
