require "./lib_terminal"

SCREEN_WIDTH  = 120
SCREEN_HEIGHT =  36
FONT_NAME     = "default"
FONT_SIZE     = 12
CAPTION       = "Medico"

enum Color : UInt32
  WHITE       = 0xFFFFFFFF,
  BLACK       = 0xFF000000,
  RED         = 0xFFFF0000,
  ORANGE      = 0xFFFF8000,
  YELLOW      = 0xFFFFFF00,
  GREEN       = 0xFF00FF00,
  CYAN        = 0xFF00FFFF,
  BLUE        = 0xFF0000FF,
  VIOLET      = 0xFFFF00FF,
  TRANSPARENT =          0,

  DARK_BLUE  = 0xFF000080,
  DARK_GREEN = 0xFF008000,
  GREY       = 0xFF808080,
  DARK_GREY  = 0xFF404040,
  SKY        = 0xFF0040FF,
end

enum QuittingState
  Quit
  Stay
end


abstract class AbstractFrontend
  abstract def update
  abstract def close
  abstract def process_inputs : QuittingState
  abstract def setcolor(color, bgcolor)
  abstract def setchar(x, y, char, color, bgcolor)
  abstract def write(x, y, string)
  abstract def write_centered(x, y, w, h, string)
  abstract def frame(x1, y1, width, height, fill)
end


class BearLibFrontend < AbstractFrontend
  include TerminalHelper

  def initialize
    Terminal.open
    Terminal.set "window: title=#{CAPTION}, size=#{SCREEN_WIDTH}x#{SCREEN_HEIGHT}"
    Terminal.set "font: #{FONT_NAME}, size=#{FONT_SIZE}"
    @savedcolor = Color::WHITE
    @savedbgcolor = Color::BLACK
    # @savedmouse = {cx: 0, cy: 0}
    # @mousemoved = false
    # @cached = false
  end

  def close
    Terminal.close
  end

  def update
    Terminal.clear
    # Draw ui
    frame 5,5,10,10
    setcolor Color::GREY,Color::DARK_GREY
    write_centered 5,5,10,10, "Hello!"
    setcolor Color::BLACK,Color::WHITE
    write 1,2,"Left mouse pressed!" if check(Terminal::TK::MOUSE_LEFT)
    setcolor Color::WHITE,Color::BLACK
    write 1,3,"Right mouse pressed!" if check(Terminal::TK::MOUSE_RIGHT)
    Terminal.refresh
    Terminal.delay 1
  end

  def process_inputs : QuittingState
    while Terminal.has_input
      key = Terminal.read
      return QuittingState::Quit if key == Terminal::TK::CLOSE
      #return QuittingState::Quit if key == Terminal::TK::ESCAPE
      p key if is_keyboard(key)
    end
    return QuittingState::Stay
  end

  def setcolor(color : Color, bgcolor : Color)
    if color
      Terminal.color color
      @savedcolor = color
    end
    if bgcolor
      Terminal.bkcolor bgcolor
      @savedbgcolor = bgcolor
    end
  end

  def setchar(x, y, char, color, bgcolor)
    Terminal.color color if color
    Terminal.bkcolor bgcolor if bgcolor
    Terminal.put x, y, char.ord
    Terminal.color @savedcolor
    Terminal.bkcolor @savedbgcolor
  end

  def write(x, y, string : String)
    Terminal.print x, y, string
  end

  def write_centered(x, y, w, h, string : String)
    Terminal.print x+(w-string.size)/2, y+h/2, string
  end

  CORNERS = {topleft: "\u250C", topright: "\u2510", bottomleft: "\u2514", bottomright: "\u2518"}
  BEAUTYCORNERS = {topleft: "\u2597", topright: "\u2596", bottomleft: "\u259D", bottomright: "\u2598"}
  SIDES = {horiz: "\u2500", vert: "\u2502"}

  def frame(x1, y1, width, height, fill : Bool = false)
    x1=x1.to_i
    y1=y1.to_i
    width=width.to_i
    height=height.to_i
    Terminal.print x1, y1, CORNERS[:topleft]+SIDES[:horiz]*(width-1) +CORNERS[:topright]
    Terminal.print x1, y1+height, CORNERS[:bottomleft]+SIDES[:horiz]*(width-1) +CORNERS[:bottomright]
    (y1+1..y1+height-1).each do |y|
      if fill
        Terminal.print x1, y, SIDES[:vert]+" "*(width-1)+SIDES[:vert]
      else
        Terminal.print x1, y, SIDES[:vert]
        Terminal.print x1+width, y, SIDES[:vert]
      end
    end
  end

end
