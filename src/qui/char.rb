class Qui::Char < Qui::Component

  attr_accessor :char, :font, :color

  FONT_SIZE = 10

  def initialize(id=:@anonymous_char, char='', x=0, y=0, *args)
    super(id, x, y)
    self.char = char
    @color = [255, 255, 255]
    @content_width  = FONT_SIZE
    @content_height = FONT_SIZE
  end

  def draw
    target.draw_font(x + char_padding, y, char, font, color: color)
  end

  def char_width
    font.get_width(char)
  end
  private :char_width

  def char_padding
    (FONT_SIZE - char_width) / 2
  end
  private :char_padding

end
