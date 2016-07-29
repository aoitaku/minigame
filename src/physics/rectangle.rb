require_relative 'geometry'

module Physics

  class Rectangle < Geometry

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

    def moment(mass)
      Physics.moment_for_box(mass, self.width, self.height)
    end

    def to_shape(body, x=0, y=0)
      Physics.box_shape(body, x, y, self.width, self.height)
    end

  end
end
