require "./frontend"

alias OnKey = Proc(Key, Bool)
alias OnClick = Proc(Nil)
alias OnMouseMove = Proc(MouseEvent, Int32, Int32, Nil)

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
  property color : ColorPair

  def frontend
    Frontend.instance
  end

  def draw
    frontend.setcolor color
    if need_frame
      frontend.frame(@x - 1, @y - 1, @width + 2, @height + 2, true)
    else
      frontend.fill(@x, @y, @width, @height)
    end
  end

  def process_mouse(event : MouseEvent, x : Int32, y : Int32)
  end

  def x2
    x + width - 1
  end

  def y2
    y + height - 1
  end

  def includes?(x, y)
    if need_frame
      (x >= @x - 1) && (x <= x2 + 1) && (y >= @y - 1) && (y <= y2 + 1)
    else
      (x >= @x) && (x <= x2) && (y >= @y) && (y <= y2)
    end
  end

  def initialize(@owner, @name, @x, @y, @width, @height)
    aowner = @owner
    @color = aowner ? aowner.color : DEF_COLOR
    @visible = true
    @need_frame = false
    @have_focus = false
  end
end

class FocusableControl < Control
  getter on_key : OnKey?

  def process_key(key : Key) : Bool
    # TODO - there was idiomatic code for it?
    on_key.try(&.call(key)) || false
  end

  def need_frame
    ow = @owner
    ow.nil? || self == ow.focused_child
  end
end

class Window < FocusableControl
  getter controls
  property focused_child : FocusableControl?

  def initialize(@owner, @name, @x, @y, @width, @height)
    super
    @controls = Array(Control).new
    @need_frame = true
    init_controls
    f = @controls.find { |x| x.is_a? FocusableControl }
    @focused_child = f.as(FocusableControl) if f
  end

  def init_controls
  end

  def process_key(key : Key) : Bool
    return true if super
    focused = @focused_child
    focused ? focused.process_key(key) : false
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

  macro controls(**args)
    {% for name, data in args %}
      {% if name.id != "self".id %}
        getter! {{name}} : {{data[0]}}
      {% end %}
    {% end %}

    def init_controls
      super
      {% for name, data in args %}
        {% if name.id == "self".id %}
          {% for key, value in data %}
            {% if key.starts_with? "on_" %}
              @{{key}} = ->{{value.id}}
            {% else %}
              @{{key}} = {{value}}
            {% end %}
          {% end %}
        {% else %}
          {% cls = data[0] %}
          {% args = data[1] %}
          @{{name}} = {{cls}}.new(self, :{{name}}, {{*args}})
          {% if data.size > 2 %}
            {% for key, value in data[2] %}
              {% if key.starts_with? "on_" %}
                {{name}}.{{key}} = ->{{value.id}}
              {% else %}
                {{name}}.{{key}} = {{value}}
              {% end %}
            {% end %}
          {% end %}
          @controls << {{name}}
        {% end %}
      {% end %}
    end
  end
end
