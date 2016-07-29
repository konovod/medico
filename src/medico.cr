require "./medico/game/*"
require "./medico/ui/*"

module Medico
  $frontend : AbstractFrontend
 
  $frontend = BearLibFrontend.new
  loop do
    $frontend.update
    break if $frontend.process_inputs == ProcessingResult::Break
  end
  $frontend.close
end
