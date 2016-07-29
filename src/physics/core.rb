module Physics

  module Elasticity
    MAX = 1.0
    MIN = 0.0
  end

  module Friction
    MAX = 1.0
    MIN = 0.0
  end

  module Group
    ALL    = 0
    OBJECT = 1
  end

  INFINITY = CP::INFINITY

  RECT_VERTS = [[-1, -1], [-1, 1], [1, 1], [1, -1]]

  def self.body(mass, moment)
    CP::Body.new(mass, moment)
  end

  def self.verts_for_rect(w, h)
    RECT_VERTS.map {|(x, y)| vec2(x * w, y * h)}
  end

  def self.box_shape(body, x, y, w, h)
    CP::Shape::Poly.new(body, verts_for_rect(w / 2, h / 2), vec2(x, y))
  end

  def self.circle_shape(body, x, y, r)
    CP::Shape::Circle.new(body, r, vec2(x, y))
  end

  def self.moment_for_box(mass, w, h)
    CP::moment_for_box(mass, w, h)
  end

  def self.moment_for_circle(mass, r)
    CP::moment_for_circle(mass, 0, r, vec2(0, 0))
  end

  class Tags

    attr_accessor :move_from

  end

end
