require "./medico/game/*"
require "json"

class Game
  getter universe : Biology::Universe
  getter doctor : Medico::Doctor
  getter day : Int32

  def initialize
    @universe = Biology::Universe.new
    @universe.generate

    @doctor = Medico::Doctor.new(@universe)
    @doctor.generate

    @doctor.start_game

    @day = 1
  end

  def reset
    @universe = Biology::Universe.new
    @universe.generate

    @doctor = Medico::Doctor.new(@universe)
    @doctor.generate
    @doctor.start_game

    @day = 1
  end

  def next_day
    @doctor.next_day

    @day += 1
  end

  def for_json
    {day: @day,
    }.to_json
  end
end
