require_relative 'element'

class Matter < Element

  extend Delegable

  attr_reader :body, :shape

  def initialize(x, y, geometry, material, mass, moment=nil, image=nil)
    super(x, y, geometry, image)
    @body = geometry.to_body(mass, moment)
    @body.p = vec2(self.x, self.y)
    @shape = geometry.to_shape(@body)
    @shape.e = material.elasticity
    @shape.u = material.friction
  end

  def sync_physics
    self.x = self.body.p.x
    self.y = self.body.p.y
  end

  def update
    sync_physics
  end

end
