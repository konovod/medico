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
    $frontend.frame(@x-1,@y-1,@width+2,@height+2) if need_frame
  end
  abstract def process_key(key : TK)
  abstract def process_mouse(event : MouseEvent, x : Int32, y : Int32)

  def includes?(x, y)
    (x >= @x)&&(x <= @x+width)&&(y >= @y)&&(y <= @y+height)
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
  end

  def process_key(key : TK)
    return ProcessingResult::Break if on_key && on_key(key)
    focused_child ? focused_child.process_key(key) : ProcessingResult::Continue
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    item = @controls.first?{|item| item.visible && item.includes?(x,y)}
    item.process_mouse(event,x,y) if item
  end

end


class Button < Control
  property text : String
  property on_click : OnClick
  def initialize(@owner, @name, @x, @y, @width, @height, @text, *, @on_click)
    super(@owner, @name, @x, @y, @width, @height)
    need_frame = true
  end

  def draw
    super
    $frontend.write_centered @x, @y, @width, @height, @text
  end
  def process_mouse(event : TK)
    #@owner.
  end
  def process_key(key : TK)
    false
  end
  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    case event
    when LeftClick
      @on_click.call()
    else
    end
  end


end
