

require "./biology.cr"
require "./effectors.cr"

module Biology

  class Universe

    getter effects_pool
    getter diseases_pool

    def initialize
      @effects_pool = Array(Effect).new
      @diseases_pool = Array(Disease).new
    end

    def random_effects (good : FLOAT, *, sys = nil, count = 1)
        #TODO optimize?
      result = [] of Effect
      while result.size < count
      #  eff =
      end
    end


  end

end
