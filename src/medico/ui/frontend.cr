SCREEN_WIDTH  = 120
SCREEN_HEIGHT =  36
FONT_NAME     = "default"
FONT_SIZE     = 12
CAPTION       = "Medico"

enum Colors : UInt32
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

class Frontend
  def initialize
    Terminal.open
    Terminal.set "window: title=#{CAPTION}, size=#{SCREEN_WIDTH}x#{SCREEN_HEIGHT}"
    Terminal.set "font: #{FONT_NAME}, size=#{FONT_SIZE}"
    @savedcolor = Colors::WHITE
    @savedbgcolor = Colors::BLACK
    # @savedmouse = {cx: 0, cy: 0}
    # @mousemoved = false
    # @cached = false
  end

  def close
    Terminal.close
  end

  #this should be moved to terminal wrapper
  private def is_release(code : Terminal::TK)
    code > Terminal::TK::KEY_RELEASED
  end
  private def is_mouse(code : Terminal::TK)
    code -= Terminal::TK::KEY_RELEASED.to_i if is_release(code)
    code >= Terminal::TK::MOUSE_LEFT && code <= Terminal::TK::MOUSE_CLICKS
  end
  private def is_keyboard(code : Terminal::TK)
    code -= Terminal::TK::KEY_RELEASED.to_i if is_release(code)
    code >= Terminal::TK::A && code < Terminal::TK::MOUSE_LEFT
  end

  private def check(code)
    Terminal.state(code) != 0
  end

  def update
    Terminal.clear
    # Draw ui
    Terminal.print 1,1,"Hello!"
    Terminal.print 1,2,"Left mouse pressed!" if check(Terminal::TK::MOUSE_LEFT)
    Terminal.print 1,3,"Right mouse pressed!" if check(Terminal::TK::MOUSE_RIGHT)
    Terminal.refresh
    Terminal.delay 1
  end

  def process_inputs : Bool
    while Terminal.has_input
      key = Terminal.read
      return true if key == Terminal::TK::CLOSE
      return true if key == Terminal::TK::ESCAPE
      p key if is_keyboard(key)
    end
    return false
  end
end
