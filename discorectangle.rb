module Physics

  PROTOTYPE_POINTS = {
    horizontal: [[-1,  0], [1, 0]],
    vertical:   [[ 0, -1], [0, 1]]
  }

  def self.obround_shape(body, w, h, r)
    CP::Shape::Segment.new(body, *points(w / 2 - r, h / 2 - r), r)
  end

  def self.moment_for_obround(mass, w, h, r)
    CP::moment_for_segment(mass, *points(w / 2 - r, h / 2 - r), r)
  end

  def self.points(h, v)
    (h > v ? PROTOTYPE_POINTS[:horizontal]
           : PROTOTYPE_POINTS[:vertical]
    ).map {|(x, y)| vec2(x * h, y * v) }
  end

end

module Geometric

  class Discorectangle

    attr_accessor :width, :height
    attr_reader :image

    def initialize(width, height)
      @width = width
      @height = height
      radius = self.radius
      @image = Image.new(width, height).circle(radius, radius, radius, C_WHITE)
      if width > height
        @image.box(radius, 0, width - radius, height - 1, C_WHITE).
          circle(width - radius, radius, radius, C_WHITE).
          circle_fill(radius, radius, radius - 1, [0,0,0,0]).
          box_fill(radius, 1, width - radius, height - 2, [0,0,0,0]).
          circle_fill(width - radius, radius, radius - 1, [0,0,0,0])
      else
        @image.box(0, radius, width - 1, height - radius, C_WHITE).
          circle(radius, height - radius, radius, C_WHITE).
          circle_fill(radius, radius, radius - 1, [0,0,0,0]).
          box_fill(1, radius, width - 2, height - radius, [0,0,0,0]).
          circle_fill(radius, height - radius, radius - 1, [0,0,0,0])
      end
    end

    def moment(mass)
      Physics.moment_for_obround(mass, self.width, self.height, self.radius)
    end

    def mid_x
      self.width / 2
    end

    def mid_y
      self.height / 2
    end

    def radius
      [self.width, self.height].min / 2
    end

    def to_shape(body, x=0, y=0)
      Physics.obround_shape(body, self.width, self.height, self.radius)
    end

  end

end
