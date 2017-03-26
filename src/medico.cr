require "./medico/game/*"
require "./medico/ui/*"

SEL_COLOR = ColorPair.new(Color::BLACK, Color::GREEN)

class MainForm < Window
  def initialize(*args)
    super
    @need_frame = false
  end

  controls(
    self: {on_key: "(key : Key) { form_key(key) }"},
    button1: {Button, {10, 10, 10, 5, "Click me"}, {on_click: :button1_click, color: SEL_COLOR}},
    label1: {Label, {10, 20, 10, 10, "1234567890x"}},
    label2: {Label, {40, 5, 10, 10, "1234567890x"}},
    listbox1: {ListBox, {40, 20, 10, 10}, {sel_color: SEL_COLOR,
                                           on_select: "(index : Int32){ listbox1_select(index) }",
                                           on_click:  "(index : Int32){ listbox1_click(index) }"}}
  )

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
