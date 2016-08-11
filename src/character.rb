require_relative 'core_ext/delegable'
require_relative 'matter'
require_relative 'anime/animative'

class Character < Matter

  include Animative
  extend Delegable

  attr_accessor :family, :vx, :vy

  delegate_to :shape, :object

  delegate_to :object, :move_from, :move_from=


  def initialize(x, y, geometry, properties, image=nil)
    super(
      x,
      y,
      geometry,
      Physics::Material.new(Physics::Elasticity::MIN, Physics::Friction::MIN),
      1,
      Physics::INFINITY,
      image
    )
    @vx = 0
    @vy = 0
    self.shape.collision_type = :character
    self.shape.group = Physics::Group::OBJECT
    self.shape.object = Physics::Tags.new
    self.move_from = vec2(self.x, self.y)
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
    self.move_from.x = self.x
    self.move_from.y = self.y
    super
    self.vx = self.body.v.x
    self.vy = self.body.v.y
    update_animation
  end

end
