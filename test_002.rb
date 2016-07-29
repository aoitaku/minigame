require 'chipmunk'
require_relative 'src/core_ext/delegable'
require_relative 'src/physics'
require 'dxruby'
require 'ostruct'

module Rectangular

  def left
    self.center_x - self.width / 2
  end

  def top
    self.center_y - self.height / 2
  end

  def right
    self.center_y + self.width / 2
  end

  def bottom
    self.center_y + self.height / 2
  end

end

class CPBox

  include Rectangular
  attr_accessor :body, :shape, :width, :height

  def initialize(x, y, width, height, mass)
    # 頂点配列作成
    verts = [CP::Vec2.new(-width/2, -height/2),
             CP::Vec2.new(-width/2, height/2),
             CP::Vec2.new(width/2, height/2),
             CP::Vec2.new(width/2, -height/2)]

    # 慣性モーメントを計算する
    moment = CP::moment_for_box(mass, width, height)

    # Bodyを作る
    @body = CP::Body.new(mass, CP::INFINITY)
    @body.p = CP::Vec2.new(x + width / 2, y + height / 2)

    # Shape作成
    @shape = CP::Shape::Poly.new(@body, verts, CP::Vec2.new(0, 0))

    # 画像作成
    @image = Image.new(width, height).box(0, 0, width - 1, height - 1, C_WHITE)

    @x, @y = x, y
    @width, @height = width, height
  end

  def center_x
    @body.p.x
  end

  def center_y
    @body.p.y
  end

  def draw
    Window.draw_rot(@body.p.x - @width / 2, @body.p.y - @height / 2, @image, @body.a * 180.0 / Math::PI)
  end
end

class Character

  include Rectangular
  extend Delegable

  attr_accessor :width, :height, :family
  attr_accessor :x, :y, :vx, :vy, :floating
  attr_reader :model

  delegate_to :model,
    :move_from,
    :move_from=,
    :on,
    :on=

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
    @image = Image.new(width, height).box(0, 0, width - 1, height - 1, C_WHITE)
    init_physics
    self.move_from = vec2(self.x, self.y)
    yield self if block_given?
  end

  def init_physics
    @model = Physics::Model.new(
      @x + @width / 2,
      @y + @height / 2,
      1,
      Physics::INFINITY
    )
    @model.init_shape_from_box(0, 0, self.width, self.height)
    @model.collision_type = :character
    @model.layers = 0b00000001
    @model.elasticity = Physics::ELASTICLESS
    @model.friction = Physics::FRICTIONLESS
  end

  def update_position
    self.move_from.x = self.x
    self.move_from.y = self.y
    self.x = self.model.x
    self.y = self.model.y
  end

  def update_velocity
    self.model.vx = self.vx
    self.model.vy = self.vy
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

  def center_x
    @model.x
  end

  def center_y
    @model.y
  end

  def draw
    Window.draw_rot(self.left, self.top, @image, @model.angle * 180.0 / Math::PI)
  end

end

class Terrain

  include Rectangular

  attr_accessor :body, :shape, :width, :height

  def initialize(type, x, y, width, height)
    @body  = Physics.static_body(x + width / 2, y + height / 2)
    @shape = Physics.box_shape(@body, 0, 0, width, height)
    @shape.e = Physics::ELASTICFUL
    @shape.u = Physics::FRICTIONLESS
    @shape.group = 1
    @shape.collision_type = :floor
    @shape.layers = 0b11111111
    @type = type
    case @type
    when :foothold
      @shape.collision_type = :conveyor
    end
    @width, @height = width, height
    @image = Image.new(@width, @height).box(0, 0, @width - 1, @height - 1, C_WHITE)
  end

  def center_x
    @body.p.x
  end

  def center_y
    @body.p.y
  end

  def draw
    Window.draw(self.left, self.top, @image)
  end
end

# Spaceクラスにメソッド追加
class CP::Space
  # StaticなBody
  STATIC_BODY = CP::Body.new_static
  STATIC_BODY.p = CP::Vec2.new(0, 0)

  def add(s)
    self.add_body(s.body) if s.body
    self.add_shape(s.shape)
  end

end

# Spaceオブジェクトを作る
space = CP::Space.new

# 重力を設定する(yを+方向に)
# CP::Vec2はベクトルを表すオブジェクト。newの引数はxとy
space.gravity = CP::Vec2.new(0, 1000)

player = Character.new(270, 0, 32, 32)

# 壁を作る
wall1 = Terrain.new(:collision, 0, 448, 640, 32)

wall2 = CPBox.new(270, 150, 100, 10, 1)
wall2.shape.e = 0 # 弾性(0.0～1.0)
wall2.shape.u = 0 # 摩擦(0.0～1.0)
wall2.shape.collision_type = :mover

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

joint = Groove.new(
  CP::Space::STATIC_BODY,
  wall2.body,
  CP::Vec2.new(480,155),
  CP::Vec2.new(150,155),
  CP::Vec2.new(0,0))



# Spaceに追加
space.add(player.model)
space.add_shape(wall1.shape)
space.add(wall2)
space.add_constraint(joint.constraint)

class CollisionHandler
  def begin(a, b, arbiter)
    return false if a.body.object.move_from.y + 16 > b.body.p.y - 5
    a.body.object.on = :mover
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

space.add_collision_handler :character, :mover, CollisionHandler.new

direction = -1
player.floating = false
player.vx = 0
player.vy = 0

# Space#stepで時間を進める。引数は秒。
Window.loop do
  player.vx += Input.x * 30
  wall2.body.v.x += 32 * direction if wall2.body.v.x.abs < 160

  if Input.key_push?(K_X)
    player.floating = !player.floating
    if player.floating
      player.model.vy = player.vy
    end
  end
  if Input.key_push?(K_SPACE)
    player.model.vy = -350
  end

  if player.floating
    unless player.on == :mover && Input.y > 0
      player.vy += Input.y * 30
    end
  end

  if player.on == :mover
    player.model.vx = player.vx + wall2.body.v.x
  else
    player.model.vx = player.vx
  end

  4.times {
    if player.floating
      player.model.vy = player.vy
    end
    space.step(1.0/240.0)
  }
  player.update_position

  direction *= -1 if wall2.body.v.x.abs < 32
  player.vx *= 0.9
  player.vy *= 0.9
  player.draw
  wall1.draw
  wall2.draw
  joint.draw
end
