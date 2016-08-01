require "./medico/game/*"
require "./medico/ui/*"

class MainForm < Window
  def initialize(*args)
    super
    @need_frame = false
  end

  # code  be macro-generated
  getter! button1
  getter! label1
  getter! listbox1

  def init_controls
    @on_key = ->(key : Key) { form_key(key) }

    @button1 = Button.new(self, :button1, 10, 10, 10, 5, "Click me", on_click: ->button1_click)
    @controls << button1
    @label1 = Label.new(self, :label1, 10, 20, 10, 10, "Label1")
    @controls << label1
    @listbox1 = ListBox.new(self, :listbox1, 40, 20, 10, 10)
    @controls << listbox1
  end

  # end of macro-generated

  def button1_click : Void
    label1.text += "A"
    listbox1.items << label1.text
  end

  def form_key(key : Key) : Bool
    if key == Terminal::TK::ESCAPE
      label1.text = "Quitting!"
      $quitting = true
      true
    else
      false
    end
  end
end

module Medico
  $frontend : AbstractFrontend
  $frontend = BearLibFrontend.new(false)
  $quitting = false
  form = MainForm.new(nil, :main, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  $frontend.main_window = form
  loop do
    $frontend.update
    break if $frontend.process_inputs == ProcessingResult::Break
    break if $quitting
  end
  $frontend.close
end
