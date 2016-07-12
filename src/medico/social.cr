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

  def fame_change(doc, patient, outcome, random = DEF_RND) : Int32
    if outcome
      rate = patient.status.level * (patient.maxhealth - patient.starting_health)
      result = stat_to_int(rate * doc.skill_power(Passive::Advertising, 20, random))
      result = random.rand(result) unless patient.is_good
    else
      rate = patient.status.level * patient.starting_health
      result = -stat_to_int(rate / doc.skill_power(Passive::Advertising, 50, random))
    end
    result
  end

  def gen_patient(doc, random = DEF_RND)
    # status = {*ALL_STATUSES, nil}.sample
    Biology::Patient.new($r)
  end
end
