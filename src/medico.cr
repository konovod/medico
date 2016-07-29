require "./medico/game/*"
require "./medico/ui/*"

module Medico
  $frontend : AbstractFrontend

  $frontend = BearLibFrontend.new
  $frontend.main_window = Window.new(nil, "Medico", 5,5,10,10)
  loop do
    $frontend.update
    break if $frontend.process_inputs == ProcessingResult::Break
  end
  $frontend.close
end
