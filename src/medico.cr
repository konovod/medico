require "./medico/game/*"
require "./medico/ui/*"

module Medico
  Terminal.open
  Terminal.refresh
  p Terminal.read
  Terminal.close
end
