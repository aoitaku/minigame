class Quincite::UI::Message < Qui::Component

  include Quincite::UI::Layouter

  attr_accessor :color
  attr_reader :components, :font, :line_height

  def initialize(id=:@anonymous_text, text='', x=0, y=0, *args)
    super(id, x, y)
    self.text = text
    self.style_set :layout, :flow
    self.style_set :align_items, :top
    self.style_set :justify_content, :left
    @line_height = 1.0
    @font = Font.default
  end

  def font=(font)
    @font = case font
    when Font
      font
    when nil
      Font.default
    when Hash
      Font.new(font[:size], font[:face])
    when Array
      Font.new(*font)
    when String
      Font.new(@font.size, font)
    else
      Font.new(@font.size, font.to_s)
    end
  end

  def text=(text)
    @text = text.to_s
  end

  def text=(text)
    @text = text.to_s
  end

  def text_align=(align)
    self.style_set :justify_content, align
  end

  def text_align
    self.style.justify_content
  end

  def draw
    return unless visible?
    super
    components.each(&:draw)
  end

  def flow_resize
    flow_segment
    super
  end

  def line_spacing
    case line_height
    when Float
      (font.size * line_height - font.size) / 2.0
    when Fixnum
      (line_height - font.size) / 2.0
    end
  end
  private :line_spacing

  def flow_segment
    text_margin = [line_spacing, 0]
    @components = @text.each_line.flat_map do |line|
      line.each_char.map {|char|
        Qui::Char.new.tap {|component|
          component.char   = char
          component.target = self.target
          component.color  = self.color
          component.font   = self.font
          component.style_set :margin, text_margin
        }
      }.tap {|line| line.last.style_set :break_after, true }
    end
  end
  private :flow_segment

end
