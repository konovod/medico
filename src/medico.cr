require "./medico/game/*"
require "./medico/ui/*"

module Medico
  # game = Frontend.new
  # loop do
  #   game.update
  #   break if game.process_inputs
  # end
  # game.close
  Terminal.input_check(Terminal::TK::MOUSE_LEFT)
  Terminal.input_state(Terminal::TK::MOUSE_RIGHT) != 0

end
