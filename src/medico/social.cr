require "./grammar"
require "./globals"
require "./data/*"

module Social
  extend self

  class Status
    getter name : Grammar::Adjective
    getter level : Int32
    getter payments : Int32

    def initialize(aname, @level, @payments)
      @name = s(aname, Grammar::Adjective)
    end
  end

  def gen_status(random = DEF_RND)
    weighted_sample(ALL_STATUSES.to_a, random, &.level)
  end
end
