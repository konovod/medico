require "./frontend"


alias OnKey = Proc(Key, Bool)
alias OnClick = Proc(Bool)
alias OnMouseMove = Proc(Int32, Int32, Bool)

abstract class Control
  getter owner : Window?
  getter name : String
  property x : Int32
  property y : Int32
  property width : Int32
  property height : Int32
  property visible : Bool
  property need_frame : Bool
  property have_focus : Bool
  property focused_child : Control?

  def frontend
    owner.frontend
  end

  def draw
    frontend.frame(@x,@y,@width,@height) if need_frame
  end
  abstract def process_key(key : TK)
  abstract def process_mouse(event : MouseEvent, x : Int32, y : Int32)

  def initialize(@owner, @name, @x, @y, @width, @height)
    @visible = true
    @need_frame = false
    @have_focus = false
  end

end


class Window < Control
  getter controls
  @frontend : AbstractFrontend?
  getter on_key : OnKey?

  def frontend
    case @owner
    when nil
      @frontend.as(AbstractFrontend)
    else
      super
    end
  end

  def initialize(@owner, @name, @x, @y, @width, @height)
    super
    @controls = Array(Control).new
  end

  def process_key(key : TK)

  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
  end

end


class Button < Control
  property text : String
  def initialize(@owner, @name, @x, @y, @width, @height, @text, *, @on_click)
    super
  end

  def draw

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
