module Physics

  ELASTICFUL = 1.0
  ELASTICLESS = 0.0
  FRICTIONFUL = 1.0
  FRICTIONLESS = 0.0

  INFINITY = CP::INFINITY

  def self.body(mass, moment)
    CP::Body.new(mass, moment)
  end

  def self.box_shape(body, x, y, w, h)
    verts = [[-1, -1], [-1, 1], [1, 1], [1, -1]].map {|(x, y)| vec2(x * w/2, y * h/2)}
    CP::Shape::Poly.new(body, verts, vec2(x, y))
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

end
