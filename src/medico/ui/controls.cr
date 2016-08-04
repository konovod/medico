require "./window"

class Button < Control
  property text : String
  property on_click : OnClick?

  def initialize(@owner, @name, @x, @y, @width, @height, @text)
    super(@owner, @name, @x, @y, @width, @height)
    @need_frame = true
  end

  def draw
    super
    frontend.write_centered @x, @y, @width, @height, @text
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    case event
    when MouseEvent::LeftClick
      @on_click.try &.call
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
    frontend.write_centered @x, @y, @width, @height, @text[0...width]
  end
end

alias OnSelectItem = Proc(Int32, Nil)
alias OnClickItem = Proc(Int32, Nil)

class ListBox < FocusableControl
  getter items
  getter position
  property sel_color : ColorPair
  property scrollable : Bool
  property scrollpos

  property on_select : OnSelectItem?
  property on_click : OnClickItem?

  def initialize(@owner, @name, @x, @y, @width, @height)
    super(@owner, @name, @x, @y, @width, @height)
    @items = [] of String
    @position = 0
    @scrollpos = 0
    @scrollable = true
    @sel_color = @color.invert
  end

  def scroll_shift
    scrollable ? 1 : 0
  end

  def position=(value)
    if items.empty?
      @scrollpos = 0
      @position = 0
      return
    end
    if value < 0
      value = 0
    elsif value >= items.size
      value = items.size - 1
    end
    return if value == @position
    @position = value
    if scrollable
      if position < scrollpos
        @scrollpos = position
      elsif position >= scrollpos + height - 1 - scroll_shift
        @scrollpos = position - height + 1 + scroll_shift
        @scrollpos -= 1 if position == items.size - 1
      end
    end
    event = on_select
    event.call(position) if event
  end

  def draw
    super
    (0..height - 1).each do |i|
      index = scrollpos + i
      s = index < items.size ? items[index] : ""
      if index == @position
        frontend.setcolor sel_color
        frontend.write @x, @y + i, " "*width
      end
      frontend.write @x, @y + i, s[0...width]
      frontend.setcolor color if index == @position
    end
    if scrollable && need_frame
      frontend.write(x, y - 1, "\u{2191}" * width) if scrollpos > 0
      frontend.write(x, y + height, "\u{2193}" * width) if scrollpos < items.size - height
    end
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
    cursor = y - @y + @scrollpos
    self.position = cursor
    return if scrollable && y == @y - 1
    return if scrollable && y == @y + height
    clicked if event == MouseEvent::LeftClick # && position == cursor
  end

  def clicked
    event = on_click
    event.call(position) if event && !items.empty?
  end

  def process_key(key : Key)
    case key
    when Terminal::TK::UP
      self.position = @position - 1
    when Terminal::TK::DOWN
      self.position = @position + 1
    when Terminal::TK::HOME
      self.position = 0
    when Terminal::TK::K_END
      self.position = @items.size - 1
    when Terminal::TK::PAGEUP
      self.position -= height
    when Terminal::TK::PAGEDOWN
      self.position += height
    when Terminal::TK::ENTER, Terminal::TK::SPACE
      clicked
    else
      return false
    end
    return true
  end
end
