require 'chipmunk'
require 'forwardable'
require 'singleton'

require_relative 'stage'
require_relative 'character'
require_relative 'event'
require_relative 'assets'

using QueriableArray

class Game

  class Switch

    def initialize
      @global_data = {}
      @event_data = {}
    end

    def []=(key, value)
      case key
      when Event
        @event_data[key.id] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Event
        @event_data[key.id]
      else
        @global_data[key]
      end
    end
  end

  class Variable

    def initialize
      @global_data = {}
      @event_data = {}
    end

    def []=(key, value)
      case key
      when Event
        @event_data[key.id] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Event
        @event_data[key.id]
      else
        @global_data[key]
      end
    end
  end

  include Singleton

  attr_accessor :target, :variables, :switches

  def initialize
    @stage = Stage.create_from_struct(Asset.load_stage(CONFIG.last_file))
    @target = RenderTarget.new(256, 240)
    @stage.target = @target

    _, _, *player_source = @stage.objects.find_by(first: :player)
    join_player(new_player(player_source))

    @enemies = []

    @switches  = Switch.new
    @variables = Variable.new

    @commands = []

    @stage.events.each {|event| event.subscribe -> args { register_command(*args) }}

    @waiting_input = false
  end

  def destruct!
    @enemies.clear
    @commands.clear
  end

  def new_character(family, x, y, width, height, properties, image)
    Character.new(
      x,
      y,
      Physics::Rectangle.new(width, height),
      properties,
      Asset.chdir{ Image.load(image) }
    ) do |character|
      character.family = family
    end
  end

  def new_player(source)
    new_character(:player, *source, "player.png")
  end

  def new_enemy(source)
    new_character(:enemy, *source, "enemy.png")
  end

  def join_player(player)
    player.target = @target
    @stage.space.add_matter(player)
    @player = player
  end

  def join_enemy(enemy)
    enemy.target = @target
    @stage.space.add_matter(enemy)
    @enemies << enemy
  end

  def register_command(command, event)
    old = @commands.find_by(event_id: event.id)
    if old
      return if old.command_id == command.id
      @commands.delete(old)
    end
    @commands << Interpreter.new(command, event)
  end

  def wait_input
    @waiting_input = true
  end

  def resolve_input
    @waiting_input = false
  end

  def waiting_input?
    @waiting_input
  end

  def update
    @commands.each(&:update)
    @commands.keep_if(&:running?)

    return if waiting_input?

    @stage.update
    @stage.auto_events.each(&:exec)
    @stage.parallel_events.each(&:exec)

    @player.move(Input.x * 28, 0)
    @player.jump if (Input.key_push?(K_SPACE) or Input.key_push?(K_X))
    @player.update
    Sprite.update(@enemies)

    Sprite.check(@stage.touchable_events, @player, :exec)
    event = @player.check(@stage.inspectable_events).first
    event.exec(@player) if event && Input.key_push?(K_UP)
  end

  def draw
    @stage.draw
    @player.draw
    Sprite.draw(@enemies)
    Window.draw_scale(
      @target.width / 2,
      @target.height / 2,
      @target,
      2,
      2
    )
  end
end

game = Game.instance

Window.width = game.target.width * 2
Window.height = game.target.height * 2
Window.mag_filter = TEXF_POINT
Window.loop do
  game.update
  game.draw
end
