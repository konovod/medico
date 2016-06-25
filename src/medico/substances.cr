require "./biology"
require "./effectors"
require "./namegen"

module Biology

  class Substance < TimedEffector
    getter name : String
    getter power : Int32

    def initialize(@name, @power)
      super()
    end

    def generate

    end


  end

  class ReactionRule < Effector
    getter substances

    def initialize
      super()
      substances = Array(Substance).new
    end

    def process(**context) : TEffectorData
      #TODO
    end



  end

end
