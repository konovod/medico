require "./window"

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

class Label < Control
  property text : String

  def initialize(@owner, @name, @x, @y, @width, @height, @text)
    super(@owner, @name, @x, @y, @width, @height)
  end

  def draw
    super
    $frontend.write_centered @x, @y, @width, @height, @text
  end
end

class ListBox < FocusableControl
  getter items
  property position
  property sel_color : ColorPair

  #  property scroll

  def initialize(*args)
    super
    @items = [] of String
    @position = 0
    @sel_color = @color.invert
  end

  def draw
    super
    @height.times do |i|
      s = i < items.size ? items[i] : ""
      $frontend.setcolor sel_color if i == @position
      $frontend.write @x, @y + i, s
      $frontend.setcolor color if i == @position
    end
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
  end

  def process_key(key : Key)
    case key
    when Terminal::TK::UP
      @position -= 1 if @position > 0
    when Terminal::TK::DOWN
      @position += 1 if @position < @items.size-1


    else
      return false
    end
    return true
  end
end
