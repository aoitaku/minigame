require_relative 'core_ext/delegable'
require_relative 'matter'
require_relative 'anime/animative'

class Character < Matter

  include Animative
  extend Delegable

  attr_accessor :family, :vx, :vy
  attr_reader :direction

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
    @direction = 0
    @durability = 0
    @action = nil
    @dying = nil
    @damaging = nil
    @event_handlers = {}
    self.shape.collision_type = :character
    self.shape.group = Physics::Group::OBJECT
    self.shape.object = Physics::Tags.new
    self.move_from = vec2(self.x, self.y)
    yield self if block_given?
  end

  def alive?
    not dying?
  end

  def damaging?
    @damaging and @damaging.alive?
  end

  def damage(power)
    @durability -= power
    damaged
    die if @durability <= 0
  end

  def damaged
    self.collision_enable = false
    @damaging = Fiber.new {
      12.times { Fiber.yield }
      self.collision_enable = true
      12.times { Fiber.yield }
    }
  end

  def dying?
    @dying and @dying.alive?
  end

  def die
    handle_event(:dead)
    self.shape.layers = 0b010
    @dying = Fiber.new do
      Fiber.yield while aerial?
      12.times { Fiber.yield }
      self.collision_enable = false
      6.times { Fiber.yield }
      dead
    end
  end

  def dead
    self.vanish
  end

  def set_handler(name, handler=Proc.new)
    @event_handlers.store(name, handler)
  end

  def handle_event(name)
    instance_exec(&@event_handlers[name]) if alive? && @event_handlers[name]
  end

  def set_action(action=Proc.new)
    @action = Fiber.new { instance_exec(&action) }
  end

  def stop_action
    @action = nil
  end

  def active?
    @action and @action.alive?
  end

  def step_action
    @action.resume
  end

  def step_dying
    @dying.resume
  end

  def move(vx, vy)
    self.body.v.x += vx
    self.body.v.y += vy
  end

  def move_forward(volume)
    self.body.v.x += volume * [-1,1][direction]
  end

  def update
    decelerate
    self.move_from.x = self.x
    self.move_from.y = self.y
    step_action if alive? and active?
    step_dying if dying?
    super
    self.vx = self.body.v.x
    self.vy = self.body.v.y
    update_animation
  end

  def aerial?
    @aerial
  end

  def jump
    @aerial = true
    @jumping = true
    handle_event(:jump)
  end

  def fall
    @aerial = true
    @jumping = false
    handle_event(:fall)
  end

  def land
    start_waiting
    @aerial = false
    @jumping = false
    handle_event(:land)
  end

  def wall(space)
    raycast_forward(space, 1).tap do |wall|
      handle_event(:wall) if wall && wall.shape.collision_type == 2
    end
  end

  def decelerate
    if aerial?
      body.v.x *= 0.9
    else
      body.v.x *= 0.85
    end
  end

  def landing(space)
    footholds = raycast_underfoot(space)
    if footholds.empty?
      fall unless aerial?
    else
      if aerial? and body.v.y.abs <= 4
        body.v.y = 0
        land
      end
    end
    footholds
  end

  def underfoot_p
    self.body.p + vec2(0, self.geometry.height / 2 + 1)
  end

  def raycast_forward(space, distance=1)
    space.segment_query_first(
      self.body.p,
      self.body.p + vec2((self.image.width / 2 + distance) * [-1,1][direction], 0),
      0b001,
      self.shape.group
    )
  end

  def raycast_underfoot(space)
    [
      space.segment_query_first(
        self.body.p + vec2(self.geometry.width / -2, 0),
        self.underfoot_p + vec2(self.geometry.width / -2, 0),
        0b011,
        self.shape.group
      ),
      space.segment_query_first(
        self.body.p + vec2(self.geometry.width / 2, 0),
        self.underfoot_p + vec2(self.geometry.width / 2, 0),
        0b011,
        self.shape.group
      )
    ].compact
  end

  def knockback(o, vx, vy)
    self.body.apply_impulse(
      vec2(vx * [-1,1][o.direction], vy),
      vec2([-1,1][o.direction] * self.geometry.width / 2, 0)
    )
  end

  def turn
    @direction = [1,0][@direction]
  end

  def turn_left
    @direction = 0
  end

  def turn_right
    @direction = 1
  end

  def start_falling
    change_animation([:fall_left, :fall_right][direction])
  end

  def start_waiting
    change_animation([:wait_left, :wait_right][direction])
  end
  alias wait start_waiting

  def start_walking
    change_animation([:walk_left, :walk_right][direction])
  end
  alias walk start_walking

  def hit_by_bullet(o)
    knockback(o, 120, -240)
    damage(1)
  end

end
