require "./frontend"

alias OnKey = Proc(Key, Bool)
alias OnClick = Proc(Nil)
alias OnMouseMove = Proc(MouseEvent, Int32, Int32, Void)

abstract class Control
  getter owner : Window?
  getter name : Symbol
  property x : Int32
  property y : Int32
  property width : Int32
  property height : Int32
  property visible : Bool
  property need_frame : Bool
  property have_focus : Bool
  property focused_child : Control?

  def draw
    $frontend.frame(@x - 1, @y - 1, @width + 2, @height + 2) if need_frame
  end

  def process_key(key : Key) : ProcessingResult
    ProcessingResult::Continue
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
  end

  def includes?(x, y)
    (x >= @x) && (x <= @x + width) && (y >= @y) && (y <= @y + height)
  end

  def initialize(@owner, @name, @x, @y, @width, @height)
    @visible = true
    @need_frame = false
    @have_focus = false
  end
end

class Window < Control
  getter controls
  getter on_key : OnKey?

  def initialize(@owner, @name, @x, @y, @width, @height)
    super
    @controls = Array(Control).new
    @need_frame = true
    init_controls
  end

  def init_controls
  end

  def process_key(key : Key)
    return ProcessingResult::Break if on_key && on_key.not_nil!.call(key)
    focused_child ? focused_child.not_nil!.process_key(key) : ProcessingResult::Continue
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    item = @controls.find { |item| item.visible && item.includes?(x, y) }
    item.process_mouse(event, x, y) if item
  end

  def draw
    super
    @controls.each do |item|
      item.draw if item.visible
    end
  end
end

class Button < Control
  property text : String
  property on_click : OnClick

  def initialize(@owner, @name, @x, @y, @width, @height, @text, *, @on_click)
    super(@owner, @name, @x, @y, @width, @height)
    @need_frame = true
  end

  def draw
    super
    $frontend.write_centered @x, @y, @width, @height, @text
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    case event
    when MouseEvent::LeftClick
      @on_click.call
    else
    end
  end
end
