require "./medico/game/*"
require "./medico/ui/*"

module Medico
  game = Frontend.new
  loop do
    game.update
    break if game.process_inputs
  end
  game.close
end
