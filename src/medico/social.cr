require "./grammar"
require "./globals"

module Social

class Status
  getter name : Grammar::Adjective
  getter level : Int32
  getter payments : Int32

  def initialize(aname, @level, @payments)
    @name = s(aname, Grammar::Adjective)
  end

end

end
