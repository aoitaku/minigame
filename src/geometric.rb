module Geometric

  class Rectangle

    attr_accessor :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def mid_x
      self.width / 2
    end

    def mid_y
      self.height / 2
    end

    def to_a
      [0, 0, self.width, self.height]
    end

    def to_body(mass, moment=nil)
      moment ||= Physics.moment_for_box(mass, self.width, self.height)
      Physics.body(mass, moment)
    end

    def to_shape(body, x=0, y=0)
      Physics.box_shape(body, x, y, self.width, self.height)
    end

  end

  class Circle

    attr_accessor :radius

    def initialize(radius)
      @radius = radius
    end

    def width
      self.radius * 2
    end

    def height
      self.radius * 2
    end

    alias mid_x radius
    alias mid_y radius

    def to_a
      [self.mid_x, self.mid_y, self.radius]
    end

    def to_body(mass, moment=nil)
      moment ||= Physics.moment_for_circle(mass, self.radius)
      Physics.body(mass, moment)
    end

    def to_shape(body, x=0, y=0)
      Physics.circle_shape(body, x, y, self.radius)
    end

  end

  attr_accessor :geometry

  def min_x
    self.x - self.geometry.mid_x
  end

  def min_y
    self.y - self.geometry.mid_y
  end

  def max_x
    self.x + self.geometry.mid_x
  end

  def max_y
    self.x + self.geometry.mid_y
  end

end
