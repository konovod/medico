require "./medico/game/*"
require "./medico/ui/*"

class MainForm < Window

  def initialize(*args)
    super
    @need_frame = false
  end

  getter! button1
  getter! label1

  def init_controls
    @button1 = Button.new(self, :button1, 10, 10, 10, 5, "Click me", on_click: ->button1_click)
    @label1 = Label.new(self, :button1, 10, 20, 10, 10, "Label1")
    @controls << button1
    @controls << label1

  end

  def button1_click() : Void
    @label1.not_nil!.text +="A"
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
