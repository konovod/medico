require "./lib_terminal"
require "./window"

SCREEN_WIDTH  = 120
SCREEN_HEIGHT =  36
FONT_NAME     = "default"
FONT_SIZE     = 12
CAPTION       = "Medico"
DEF_COLOR = ColorPair.new(Color::WHITE, Color::BLACK)

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

  def self.rgba(r, g, b, a = 255) : Color
    aa = a.clamp(0, 255)
    rr = r.clamp(0, 255)
    gg = g.clamp(0, 255)
    bb = b.clamp(0, 255)
    Color.new(0_u32 + (aa << 24) + (rr << 16) + (gg << 8) + bb)
  end
end

struct ColorPair
  property fg : Color
  property bg : Color
  def initialize(@fg,@bg)
  end

  def invert!
    @bg, @fg = @fg, @bg
    self
  end

  def invert
    return ColorPair.new(@bg, @fg)
  end
end



class String
  def to_color : Color
    Color.new(Terminal.color_from_name(self.downcase.tr("_", " ")))
  end
end

enum ProcessingResult
  Break
  Continue
end

enum MouseEvent
  LeftClick
  Move
  # TODO - others?
end

alias Key = Terminal::TK

abstract class AbstractFrontend
  property main_window : Window
  property quitting : Bool

  abstract def update
  abstract def close
  abstract def process_inputs : ProcessingResult
  abstract def setcolor(color, bgcolor)
  abstract def setchar(x, y, char, color, bgcolor)
  abstract def write(x, y, string)
  abstract def write_centered(x, y, w, h, string)
  abstract def frame(x1, y1, width, height, fill)

  def initialize
    @main_window = Window.new(nil, "", 0, 0, 1, 1)
    @quitting = false
  end
end

class BearLibFrontend < AbstractFrontend
  include TerminalHelper
  getter realtime : Bool

  def initialize(@realtime)
    Terminal.open
    Terminal.set "window: title=#{CAPTION}, size=#{SCREEN_WIDTH}x#{SCREEN_HEIGHT}"
    Terminal.set "font: #{FONT_NAME}, size=#{FONT_SIZE}"
    @savedcolor = Color::WHITE
    @savedbgcolor = Color::BLACK
    @main_window = Window.new(nil, :main, 0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1)
    @main_window.need_frame = false

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
    @main_window.draw unless @main_window.nil?
    Terminal.refresh
    Terminal.delay 1
  end

  private def handle_input(input : Terminal::TK)
    case input
    when Terminal::TK::CLOSE
      return ProcessingResult::Break
    when Terminal::TK::MOUSE_LEFT + Terminal::TK::KEY_RELEASED.to_i
      @main_window.process_mouse(MouseEvent::LeftClick,
        Terminal.state(Terminal::TK::MOUSE_X),
        Terminal.state(Terminal::TK::MOUSE_Y))
      # TODO - check case syntax
    else
      @main_window.process_key(input) if is_keyboard(input)
    end
    ProcessingResult::Continue
  end

  def process_inputs : ProcessingResult
    return ProcessingResult::Break if @quitting
    if @realtime
      while Terminal.has_input
        key = Terminal.read
        return handle_input(key)
        # return ProcessingResult::Break if key == Terminal::TK::ESCAPE
        # p key if is_keyboard(key)
      end
      return ProcessingResult::Continue
    else
      return handle_input(Terminal.read) # TODO - flag if refresh is required
    end
  end

  def setcolor(pair : ColorPair)
    setcolor(pair.fg, pair.bg)
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
    Terminal.print x + (w - string.size)/2, y + h/2, string
  end

  CORNERS = {topleft: "\u250C", topright: "\u2510", bottomleft: "\u2514", bottomright: "\u2518"}
  SIDES   = {horiz: "\u2500", vert: "\u2502"}

  def fill(x1, y1, width, height)
    (y1..y1 + height-1).each do |y|
        Terminal.print x1, y, " "*width
    end
  end

  def frame(x1, y1, width, height, fill : Bool = false)
    Terminal.print x1, y1, CORNERS[:topleft] + SIDES[:horiz]*(width - 2) + CORNERS[:topright]
    Terminal.print x1, y1 + height-1, CORNERS[:bottomleft] + SIDES[:horiz]*(width - 2) + CORNERS[:bottomright]
    (y1 + 1..y1 + height - 2).each do |y|
      if fill
        Terminal.print x1, y, SIDES[:vert] + " "*(width - 2) + SIDES[:vert]
      else
        Terminal.print x1, y, SIDES[:vert]
        Terminal.print x1 + width-1, y, SIDES[:vert]
      end
    end
  end
end
