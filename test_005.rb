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

class SliderLift

  attr_reader :lift, :slider, :motor, :motor_shaft, :connector
  attr_accessor :motor_power

  def initialize(x, y, geometry, dist, angle)
    @lift = Matter.new(x, y, geometry, 1, Physics::INFINITY)
    @lift.shape.e = 0
    @lift.shape.u = 0
    @lift.shape.collision_type = :lift
    @lift.body.object = nil
    @motor_power = 0

    angle = angle * Math::PI / 180.0
    point = vec2(dist, 0).rotate(CP::Vec2.for_angle(angle))
    motor_center = vec2(dist / 2, 0).rotate(CP::Vec2.for_angle(angle))

    @slider = CP::Constraint::GrooveJoint.new(
      CP::Space::STATIC_BODY,
      @lift.body,
      vec2(@lift.x, @lift.y),
      vec2(@lift.x + point.x, @lift.y + point.y),
      vec2(0, 0)
    )
    @motor = Matter.new(
      @lift.x - motor_center.x - dist / 2,
      @lift.y - motor_center.y - dist / 2,
      Geometric::Circle.new(dist / 2), 1)
    @motor.shape.layers = 0b00
    @motor_shaft = CP::Constraint::PinJoint.new(
      CP::Space::STATIC_BODY,
      @motor.body,
      vec2(@lift.x - motor_center.x, @lift.y - motor_center.y),
      vec2(0, 0),
    )
    @motor_shaft.dist = 0
    @motor.body.a = angle

    @connector = CP::Constraint::PinJoint.new(
      @lift.body,
      @motor.body,
      vec2(0, 0),
      vec2(-dist / 2, 0),
    )
    @connector.dist = dist
  end

  def set_handler(handler)
    @lift.body.object = handler
  end

  def draw
    Window.draw_line(
      @slider.groove_a.x.round,
      @slider.groove_a.y.round,
      @slider.groove_b.x.round,
      @slider.groove_b.y.round, C_YELLOW)
    Window.draw_circle_fill(
      @lift.x.round,
      @lift.y.round,
      4, C_YELLOW)
    b = @motor.body.p + @motor_shaft.anchr2
    Window.draw_line(
      @motor_shaft.anchr1.x.round,
      @motor_shaft.anchr1.y.round,
      b.x.round,
      b.y.round, C_YELLOW)
    a = @lift.body.p + @connector.anchr1
    b = @motor.body.p + @connector.anchr2.rotate(CP::Vec2.for_angle(@motor.body.a))
    Window.draw_line(
      a.x.round,
      a.y.round,
      b.x.round,
      b.y.round, C_YELLOW)
    @motor.draw
    @lift.draw
  end

  def step
    @motor.body.w = self.motor_power
  end

end

space = CP::Space.new
space.gravity = vec2(0, 1000)

player = Character.new(270, 0, Geometric::Rectangle.new(24, 32))

wall1 = Terrain.new(0, 448, Geometric::Rectangle.new(640, 32))

lift1 = SliderLift.new(320, 160, Geometric::Rectangle.new(100, 10), 160, -150)
lift2 = SliderLift.new(160, 160, Geometric::Rectangle.new(100, 10), 160, 60)


lift1.motor_power = 1
lift1.set_handler({on: -> { lift1.motor_power = 2 },
  off: -> { lift1.motor_power = 1 }})

lift2.motor_power = 2
lift2.set_handler({on: -> { lift2.motor_power = 1 },
  off: -> { lift2.motor_power = 2 }})

# Spaceに追加
space.add(player)
space.add_shape(wall1.shape)
space.add(lift1.lift)
space.add(lift2.lift)
space.add(lift1.motor)
space.add(lift2.motor)
space.add_constraint(lift1.slider)
space.add_constraint(lift1.motor_shaft)
space.add_constraint(lift1.connector)
space.add_constraint(lift2.slider)
space.add_constraint(lift2.motor_shaft)
space.add_constraint(lift2.connector)

class CollisionHandler
  def begin(a, b, arbiter)
    return false if a.body.object.move_from.y + 16 > b.body.p.y - 4
    a.body.object.on = b
    b.body.object[:on].call if b.body.object
    @a = a
    @b = b
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
    return unless @b
    @b.body.object[:off].call if @b.body.object
    @b = nil
  end
end

space.add_collision_handler :character, :lift, CollisionHandler.new

direction = -1
player.floating = false
player.vx = 0
player.vy = 0

# Space#stepで時間を進める。引数は秒。
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
    player.step
    lift1.step
    lift2.step
    space.step(1.0/240.0)
  }
  player.update_position

  player.vx *= 0.9
  player.vy *= 0.9
  player.draw
  wall1.draw
  lift1.draw
  lift2.draw
end
