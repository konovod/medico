require "./medico/game/*"
require "./medico/ui/*"
require "./medico/gameui/*"

module Medico
  frontend = BearLibFrontend.new(false, MainForm)
  form = frontend.main_window.as(MainForm)
  loop do
    form.label2.text = "#{Terminal.state(Terminal::TK::MOUSE_X)}, #{Terminal.state(Terminal::TK::MOUSE_Y)}"
    frontend.update
    break if frontend.process_inputs == ProcessingResult::Break
  end
  frontend.close
end
