require_relative '../geometric'

class Collision

  class Data < Struct.new(:type, :id, :x, :y, :width, :height, :properties)
  end

  include Geometric

  attr_accessor :type, :x, :y
  attr_reader :body, :shape

  def initialize(type, id, x, y, geometry, properties)
    @id = id
    @geometry = geometry
    @x = x + geometry.mid_x
    @y = y + geometry.mid_y
    @shape = geometry.to_shape(Physics::Space.static_body, self.x, self.y)
    @shape.e = Physics::Elasticity::MAX
    @shape.u = Physics::Friction::MIN
    @shape.collision_type = @type
  end

  def self.create_from_struct(struct)
    self.new(
      struct.type,
      struct.id,
      struct.x,
      struct.y,
      Physics::Rectangle.new(struct.width, struct.height),
      struct.properties
    )
  end

end
