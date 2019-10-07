require "../game/*"
require "json"
require "./json"

class Game
  getter universe : Biology::Universe
  getter doctor : Medico::Doctor

  def initialize
    @universe = Biology::Universe.new
    @universe.generate

    @doctor = Medico::Doctor.new(@universe)
    @doctor.generate

    @doctor.start_game
  end

  def reset
    @universe = Biology::Universe.new
    @universe.generate

    @doctor = Medico::Doctor.new(@universe)
    @doctor.generate
    @doctor.start_game
  end

  def next_day
    @doctor.next_day
  end

  def for_json
    {doctor:   @doctor.for_json,
     patients: @doctor.patients.map(&.for_json),
     askers:   @doctor.askers.map(&.for_json),
    }.to_json
  end
end
