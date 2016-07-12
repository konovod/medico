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
    ALL_STATUSES.weighted_sample(random, &.level)
  end

  def fame_change(doc, patient, result) : Int32
  end
end
