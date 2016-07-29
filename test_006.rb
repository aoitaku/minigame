require 'chipmunk'
require_relative 'src/core_ext/delegable'
require_relative 'src/physics'
require 'dxruby'
require 'ostruct'

module Geometric

  class Rectangle

    attr_accessor :width, :height
    attr_reader :image

    def initialize(width, height)
      @width = width
      @height = height
      @image = Image.new(self.width, self.height).
        box(0, 0, self.width - 1, self.height - 1, C_WHITE)
    end

    def moment(mass)
      Physics.moment_for_box(mass, self.width, self.height)
    end

    def mid_x
      self.width / 2
    end

    def mid_y
      self.height / 2
    end

    def to_shape(body, x=0, y=0)
      Physics.box_shape(body, x, y, self.width, self.height)
    end

  end

  class Circle

    attr_accessor :radius
    attr_reader :image

    def initialize(radius)
      @radius = radius
      @image = Image.new(self.width, self.height).
        circle(self.mid_x, self.mid_y, self.radius, C_WHITE).
        line(0, self.mid_y, self.mid_x, self.mid_y, C_YELLOW)
    end

    def moment(mass)
      Physics::moment_for_circle(mass, self.radius)
    end

    def width
      self.radius * 2
    end

    def height
      self.radius * 2
    end

    alias mid_x radius
    alias mid_y radius

    def to_shape(body)
      Physics.circle_shape(body, 0, 0, self.radius)
    end

  end

  attr_accessor :geometry

  def min_x
    self.x - self.geometry.mid_x
  end

  def min_y
    self.y - self.geometry.mid_y
  end

  def max_x
    self.x + self.geometry.mid_x
  end

  def max_y
    self.x + self.geometry.mid_y
  end

end

class Matter

  include Geometric

  attr_accessor :body, :shape

  def initialize(x, y, geometry, mass, moment=nil)
    @geometry = geometry
    moment ||= self.geometry.moment(mass)
    @body = CP::Body.new(mass, moment)
    @body.p = vec2(x + geometry.mid_x, y + geometry.mid_y)
    @shape = geometry.to_shape(@body)
  end

  def x
    @body.p.x
  end

  def y
    @body.p.y
  end

  def a
    @body.a
  end

  def draw
    Window.draw_rot(self.min_x.round, self.min_y.round, self.geometry.image, self.a * 180.0 / Math::PI)
  end

end

class Character < Matter

  extend Delegable

  attr_accessor :width, :height, :family
  attr_accessor :vx, :vy, :floating

  delegate_to :body,
    :object

  delegate_to :object,
    :move_from,
    :move_from=,
    :on,
    :on=

  def initialize(x, y, geometry)
    super(x, y, geometry, 1, Physics::INFINITY)
    self.body.object = Physics::MetaData.new
    self.shape.collision_type = :character
    self.shape.layers = 0b00000001
    self.shape.e = Physics::ELASTICLESS
    self.shape.u = Physics::FRICTIONLESS
    self.move_from = vec2(self.x, self.y)
    yield self if block_given?
  end

  def update_position
    self.move_from.x = self.x
    self.move_from.y = self.y
  end

  def update_velocity
    self.body.v.x = self.vx
    self.body.v.y = self.vy
  end

  def move(vx, vy)
    self.vx += vx
    self.vy += vy
  end

  def jump
    self.vy = -350
  end

  def update
    update_velocity
    update_position
    self.vx *= 0.9
    self.vy *= 0.9
  end

  def draw
    Window.draw(self.min_x, self.min_y, self.geometry.image)
  end

  def step
    self.body.v.y = self.vy if self.floating
  end

end

class Terrain

  include Geometric

  attr_accessor :x, :y, :shape

  def initialize(x, y, geometry)
    @x = x + geometry.mid_x
    @y = y + geometry.mid_y
    @geometry = geometry
    @body  = CP::Space::STATIC_BODY
    @shape = geometry.to_shape(@body, self.x, self.y)
    @shape.e = Physics::ELASTICFUL
    @shape.u = Physics::FRICTIONLESS
    @shape.group = 1
    @shape.collision_type = :floor
    @shape.layers = 0b11111111
    @shape.collision_type = :collision
  end

  def draw
    Window.draw(self.min_x, self.min_y, self.geometry.image)
  end

end

class CP::Space
  STATIC_BODY = CP::Body.new_static
  STATIC_BODY.p = vec2(0, 0)

  def add(s)
    self.add_body(s.body) if s.body
    self.add_shape(s.shape)
  end

end

class Groove

  attr_reader :constraint, :a, :b, :body_a, :body_b, :anchor

  def initialize(body_a, body_b, a, b, anchor)
    @constraint = CP::Constraint::GrooveJoint.new(
      body_a,
      body_b,
      a,
      b,
      anchor
    )
    @a = a
    @b = b
    @body_a = body_a
    @body_b = body_b
    @anchor = anchor
  end

  def draw
    Window.draw_line(body_a.p.x + a.x, body_a.p.y + a.y, body_a.p.x + b.x, body_a.p.y + b.y, C_YELLOW)
    Window.draw_circle_fill(body_b.p.x + anchor.x, body_b.p.y + anchor.y, 4, C_YELLOW)
  end

end

class Pin

  attr_reader :constraint, :body_a, :body_b, :anchor_a, :anchor_b, :dist

  def initialize(body_a, body_b, anchor_a, anchor_b, dist)
    @constraint = CP::Constraint::PinJoint.new(
      body_a,
      body_b,
      anchor_a,
      anchor_b
    )
    @anchor_a = anchor_a
    @anchor_b = anchor_b
    @body_a = body_a
    @body_b = body_b
    @dist = dist
    @constraint.dist = dist
  end

  def draw
    a = body_a.p + anchor_a.rotate(CP::Vec2.for_angle(body_a.a))
    b = body_b.p + anchor_b.rotate(CP::Vec2.for_angle(body_b.a))
    Window.draw_line(
      a.x,
      a.y,
      b.x,
      b.y, C_YELLOW)
  end

end

space = CP::Space.new
space.gravity = vec2(0, 1000)

player = Character.new(270, 0, Geometric::Rectangle.new(24, 32))
wall1 = Terrain.new(0, 448, Geometric::Rectangle.new(640, 32))

circle1 = Matter.new(80, -40, Geometric::Circle.new(160), 1)
circle1.shape.layers = 0b00
circle1.body.a = -90 * Math::PI / 180

circle2 = Matter.new(440, 120, Geometric::Circle.new(40), 1)
circle2.shape.layers = 0b00
circle2.body.a = -90 * Math::PI / 180

lift = Matter.new(190, 275, Geometric::Rectangle.new(100, 10), 1, Physics::INFINITY)
lift.shape.e = 0
lift.shape.u = 0
lift.shape.collision_type = :lift
lift.body.object = nil

joint3 = Pin.new(
  circle1.body,
  lift.body,
  CP::Vec2.new(-160,0),
  CP::Vec2.new(0,0),
  0
)

joint4 = Pin.new(
  CP::Space::STATIC_BODY,
  circle1.body,
  CP::Vec2.new(240,120),
  CP::Vec2.new(0, 0),
  0)

joint5 = Pin.new(
  CP::Space::STATIC_BODY,
  circle2.body,
  CP::Vec2.new(480,160),
  CP::Vec2.new(0,0),
  0)

joint6 = Pin.new(
  circle1.body,
  circle2.body,
  CP::Vec2.new(-60,0),
  CP::Vec2.new(-40,0),
  240
)

# Spaceに追加
space.add(player)
space.add_shape(wall1.shape)
space.add(lift)
space.add(circle1)
space.add(circle2)
space.add_constraint(joint3.constraint)
space.add_constraint(joint4.constraint)
space.add_constraint(joint5.constraint)
space.add_constraint(joint6.constraint)

class CollisionHandler
  def begin(a, b, arbiter)
    return false if a.body.object.move_from.y + 16 > b.body.p.y - 4
    a.body.object.on = b
    @a = a
  end

  def pre_solve(a, b)
    true
  end

  def post_solve(arbiter)
    true
  end

  def separate
    return unless @a
    @a.body.object.on = nil
    @a = nil
  end
end

space.add_collision_handler :character, :lift, CollisionHandler.new

direction = -1
player.floating = false
player.vx = 0
player.vy = 0

Window.loop do
  player.vx += Input.x * 30

  if Input.key_push?(K_X)
    player.floating = !player.floating
    if player.floating
      player.body.v.y = player.vy
    end
  end
  if Input.key_push?(K_SPACE)
    player.body.v.y = -350
  end

  if player.floating
    unless player.on && Input.y > 0
      player.vy += Input.y * 30
    end
  end

  if player.on
    player.body.v.x = player.vx + player.on.body.v.x
  else
    player.body.v.x = player.vx
  end

  4.times {
    circle2.body.w = -2
    if player.floating
      player.body.v.y = player.vy
    end
    space.step(1.0/240.0)
  }
  player.update_position

  player.vx *= 0.9
  player.vy *= 0.9
  player.draw
  wall1.draw
  lift.draw
  circle1.draw
  circle2.draw
  joint3.draw
  joint4.draw
  joint5.draw
  joint6.draw
end
