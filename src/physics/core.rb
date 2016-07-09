module Physics

  ELASTICFUL = 1.0
  ELASTICLESS = 0.0
  FRICTIONFUL = 1.0
  FRICTIONLESS = 0.0

  INFINITY = CP::INFINITY

  PROTOTYPE_VERTS = [[-1, -1], [-1, 1], [1, 1], [1, -1]]

  def self.static_body(x, y)
    CP::Body.new_static.tap{|body| body.p = vec2(x, y) }
  end

  def self.body(x, y, mass, moment)
    CP::Body.new(mass, moment).tap{|body| body.p = vec2(x, y) }
  end

  def self.box_shape(body, x, y, w, h)
    CP::Shape::Poly.new(body, verts(w / 2, h / 2), vec2(x, y))
  end

  def self.circle_shape(body, x, y, r)
    CP::Shape::Circle.new(body, r, vec2(x, y))
  end

  def self.verts(h, v)
    PROTOTYPE_VERTS.map {|(x, y)| vec2(x * h, y * v) }
  end

end
