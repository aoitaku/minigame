require_relative 'core_ext/delegable'
require_relative 'physics/model'

class Character < Sprite

  extend Delegable

  attr_accessor :width, :height, :family
  attr_reader :model

  delegate_to :model,
    :move_from,
    :move_from=,
    :vx,
    :vx=,
    :vy,
    :vy=

  def initialize(x, y, width, height, image)
    super(x, y, image)
    @width = width
    @height = height
    init_sprite
    init_physics
    self.move_from = vec2(self.x, self.y)
  end

  def init_sprite
    self.center_x = self.width  / 2
    self.center_y = self.height / 2
    self.offset_sync = true
    self.collision = [0, 0, self.width, self.height]
  end

  def init_physics
    @model = Physics::Model.new(
      self.x + self.center_x,
      self.y - self.center_y,
      1,
      Physics::INFINITY
    )
    @model.init_shape_from_box(*self.collision)
    @model.collision_type = 2
    @model.layers = 0b00000001
  end

  def update_position
    self.move_from.x = self.x
    self.move_from.y = self.y
    self.x = self.model.x
    self.y = self.model.y
  end

  def move(vx, vy)
    self.vx += vx
    self.vy += vy
  end

  def jump
    self.vy = 0
    -350
  end

  def update
    self.vx *= 0.9
    update_position
  end

end
