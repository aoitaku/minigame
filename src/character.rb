require_relative 'core_ext/delegable'
require_relative 'material'
require_relative 'matter'
require_relative 'physics/model'

class Character < Matter

  attr_accessor :family, :vx, :vy

  def initialize(x, y, geometry, properties, image)
    super(
      x,
      y,
      geometry,
      Material.new(Physics::ELASTICLESS, Physics::FRICTIONLESS),
      1,
      Physics::INFINITY,
      image
    )
    @vx = 0
    @vy = 0
    self.shape.collision_type = :character
    self.shape.layers = 0b00000001
    self.shape.object = Physics::MetaData.new
    self.shape.object.move_from = vec2(self.x, self.y)
    yield self if block_given?
  end

  def move(vx, vy)
    self.body.v.x += vx
    self.body.v.y += vy
  end

  def jump
    self.body.v.y = -350
  end

  def update
    self.body.v.x *= 0.9
    self.shape.object.move_from.x = self.x
    self.shape.object.move_from.y = self.y
    super
  end

end
