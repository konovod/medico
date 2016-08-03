require "./medico/game/*"
require "./medico/ui/*"

SEL_COLOR = ColorPair.new(Color::BLACK, Color::GREEN)

class MainForm < Window
  def initialize(*args)
    super
    @need_frame = false
  end

  # code will be macro-generated
  getter! button1
  getter! label1
  getter! label2
  getter! listbox1

  def init_controls
    @on_key = ->(key : Key) { form_key(key) }
    @button1 = Button.new(self, :button1, 10, 10, 10, 5, "Click me", on_click: ->button1_click)
    button1.color = SEL_COLOR
    @controls << button1
    @label1 = Label.new(self, :label1, 10, 20, 10, 10, "1234567890x")
    @controls << label1
    @label2 = Label.new(self, :label2, 40, 5, 10, 10, "1234567890x")
    @controls << label2
    @listbox1 = ListBox.new(self, :listbox1, 40, 20, 10, 10, true)
    listbox1.sel_color = SEL_COLOR
    listbox1.on_select = ->(index : Int32) { listbox1_select(index) }
    listbox1.on_click = ->(index : Int32) { listbox1_click(index) }
    @controls << listbox1
  end

  # end of macro-generated

  @aitem = 0

  def button1_click : Nil
    @aitem += 1
    listbox1.items << "Item #{@aitem}" + "."*@aitem
  end

  def listbox1_select(index : Int32) : Nil
    label1.text = listbox1.items[index]
  end

  def listbox1_click(index : Int32) : Nil
    listbox1.items[index] = "!" + listbox1.items[index]
  end

  def form_key(key : Key) : Bool
    if key == Terminal::TK::ESCAPE
      label1.text = "Quitting!"
      frontend.quitting = true
      true
    else
      false
    end
  end
end

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
