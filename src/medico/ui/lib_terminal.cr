@[Link("BearLibTerminal")]
lib Terminal

  alias Color = UInt32
  alias Int = LibC::Int

  enum TK : Int
  # If key was released instead of pressed, it's code will be OR'ed with VK_KEY_RELEASED.
    RELEASE = 0x100
    A           = 0x04
    B           = 0x05
    C           = 0x06
    D           = 0x07
    E           = 0x08
    F           = 0x09
    G           = 0x0A
    H           = 0x0B
    I           = 0x0C
    J           = 0x0D
    K           = 0x0E
    L           = 0x0F
    M           = 0x10
    N           = 0x11
    O           = 0x12
    P           = 0x13
    Q           = 0x14
    R           = 0x15
    S           = 0x16
    T           = 0x17
    U           = 0x18
    V           = 0x19
    W           = 0x1A
    X           = 0x1B
    Y           = 0x1C
    Z           = 0x1D
    K_1           = 0x1E
    K_2           = 0x1F
    K_3           = 0x20
    K_5           = 0x22
    K_4           = 0x21
    K_6           = 0x23
    K_7           = 0x24
    K_8           = 0x25
    K_9           = 0x26
    K_0           = 0x27
    RETURN      = 0x28
    ENTER       = 0x28
    ESCAPE      = 0x29
    BACKSPACE   = 0x2A
    TAB         = 0x2B
    SPACE       = 0x2C
    MINUS       = 0x2D
    EQUALS      = 0x2E
    LBRACKET    = 0x2F
    RBRACKET    = 0x30
    BACKSLASH   = 0x31
    SEMICOLON   = 0x33
    APOSTROPHE  = 0x34
    GRAVE       = 0x35
    COMMA       = 0x36
    PERIOD      = 0x37
    SLASH       = 0x38
    F1          = 0x3A
    F2          = 0x3B
    F3          = 0x3C
    F4          = 0x3D
    F5          = 0x3E
    F6          = 0x3F
    F7          = 0x40
    F8          = 0x41
    F9          = 0x42
    F10         = 0x43
    F11         = 0x44
    F12         = 0x45
    PAUSE       = 0x48
    INSERT      = 0x49
    HOME        = 0x4A
    PAGEUP      = 0x4B
    DELETE      = 0x4C
    K_END         = 0x4D
    PAGEDOWN    = 0x4E
    RIGHT       = 0x4F
    LEFT        = 0x50
    DOWN        = 0x51
    UP          = 0x52
    KP_DIVIDE   = 0x54
    KP_MULTIPLY = 0x55
    KP_MINUS    = 0x56
    KP_PLUS     = 0x57
    KP_ENTER    = 0x58
    KP_1        = 0x59
    KP_2        = 0x5A
    KP_3        = 0x5B
    KP_4        = 0x5C
    KP_5        = 0x5D
    KP_6        = 0x5E
    KP_7        = 0x5F
    KP_8        = 0x60
    KP_9        = 0x61
    KP_0        = 0x62
    KP_PERIOD   = 0x63
    SHIFT       = 0x70
    CONTROL     = 0x71
    ALT         = 0x72

  # Mouse events/states.
    MOUSE_LEFT    = 0x80 # Buttons
    MOUSE_RIGHT   = 0x81
    MOUSE_MIDDLE  = 0x82
    MOUSE_X1      = 0x83
    MOUSE_X2      = 0x84
    MOUSE_MOVE    = 0x85 # Movement event
    MOUSE_SCROLL  = 0x86 # Mouse scroll event
    MOUSE_X       = 0x87 # Cusor position in cells
    MOUSE_Y       = 0x88
    MOUSE_PIXEL_X = 0x89 # Cursor position in pixels
    MOUSE_PIXEL_Y = 0x8A
    MOUSE_WHEEL   = 0x8B # Scroll direction and amount
    MOUSE_CLICKS  = 0x8C # Number of consecutive clicks

    # Other events.
    CLOSE   = 0xE0
    RESIZED = 0xE1
  end

  # Virtual key-codes for internal terminal states/variables.
  # These can be accessed via state = terminal_state function.
  enum State : Int
    WIDTH       = 0xC0 # Terminal width in cells
    HEIGHT      = 0xC1 # Terminal height in cells
    CELL_WIDTH  = 0xC2 # Cell width in pixels
    CELL_HEIGHT = 0xC3 # Cell height in pixels
    COLOR       = 0xC4 # Current foregroung color
    BKCOLOR     = 0xC5 # Current background color
    LAYER       = 0xC6 # Current layer
    COMPOSITION = 0xC7 # Current composition state
    CHAR        = 0xC8 # Translated ANSI code of last produced character
    WCHAR       = 0xC9 # Unicode codepoint of last produced character
    EVENT       = 0xCA # Last dequeued event
    FULLSCREEN  = 0xCB # Fullscreen state
  end


  # Generic mode enum. Used in Terminal.composition call only.
  enum Composition
    OFF = 0
    ON  = 1
  end

  READ_STR_NONE = 0
  READ_STR_CANCELLED = -1

  #control functions
  fun open = terminal_open : Int
  fun close = terminal_close
  fun set = terminal_set8(value : UInt8*) : Int
  fun get = terminal_get8(key : UInt8*, default_ : UInt8*) : UInt8*
  fun refresh = terminal_refresh
  #output
  fun clear = terminal_clear
  fun clear_area = terminal_clear_area(x : Int, y : Int, w : Int, h : Int)
  fun crop = terminal_crop(x : Int, y : Int, w : Int, h : Int)
  fun layer = terminal_layer(index : Int)
  fun color = terminal_color(color : Color)
  fun bkcolor = terminal_bkcolor(color : Color)
  fun composition = terminal_composition(mode : Composition)
  fun put = terminal_put(x : Int, y : Int, code : Int)
  fun put_ext = terminal_put_ext(x : Int, y : Int, dx : Int, dy : Int, code : Int, corners : Color*)
  fun pick = terminal_pick(x : Int, y : Int, index : Int) : Int
  fun pick_color = terminal_pick_color(x : Int, y : Int, index : Int) : Color
  fun pick_bkcolor = terminal_pick_bkcolor(x : Int, y : Int) : Color
  fun print = terminal_print8(x : Int, y : Int, s : UInt8*) : Int
  #input
  fun read_str = terminal_read_str8(x : Int, y : Int, buffer : UInt8*, max : Int) : Int
  fun has_input = terminal_has_input : Bool
  #input (with enums)
  fun raw_state = terminal_state(code : State) : Int
  fun state = terminal_state(code : State) : Int
  fun input_state = terminal_state(code : TK) : Int
  fun peek = terminal_peek : TK
  fun read = terminal_read : TK

  #utility
  fun measure = terminal_measure8(s : UInt8*) : Int
  fun delay = terminal_delay(period : Int)
  fun color_from_name = color_from_name8(name : UInt8*) : Color
end
