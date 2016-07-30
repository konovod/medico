require "./medico/game/*"
require "./medico/ui/*"

class MainForm < Window
  def initialize(*args)
    super
    @need_frame = false
  end

  def init_controls
    @controls << Button.new(self, :button1, 10, 10, 10, 10, "Click me", on_click: ->button1_click)
  end

  def button1_click
    puts "Hello!"
  end
end

module Medico
  $frontend : AbstractFrontend

  $frontend = BearLibFrontend.new(false)
  form = MainForm.new(nil, :main, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  $frontend.main_window = form
  loop do
    $frontend.update
    break if $frontend.process_inputs == ProcessingResult::Break
  end
  $frontend.close
end
