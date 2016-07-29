require_relative 'geometry'

module Physics

  class Circle < Geometry

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

    def moment(mass)
      Physics.moment_for_circle(mass, self.radius)
    end

    def to_shape(body, x=0, y=0)
      Physics.circle_shape(body, x, y, self.radius)
    end

  end
end
