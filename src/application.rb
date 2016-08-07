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
        @event_data[key.to_sym] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Event
        @event_data[key.to_sym]
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
        @event_data[key.to_sym] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Event
        @event_data[key.to_sym]
      else
        @global_data[key]
      end
    end
  end

  include Singleton

  attr_accessor :target, :variables, :switches

  def initialize
    @target = RenderTarget.new(256, 240)
    @enemies = []
    @switches  = Switch.new
    @variables = Variable.new
    @current_proc = nil
    @parallel_procs = []

    setup_stage_from_file(CONFIG.last_file)

    _, _, *player_source = @stage.objects.find_by(first: :player)
    join_player(new_player(player_source))

    setup_events
  end

  def setup_events
    @stage.events.each do |event|
      event.subscribe -> args { run_event(*args) }
      event.target = @target
    end
  end

  def transport(id, x, y)
    destruct!
    setup_stage_from_file("#{id}.rb")
    setup_events
    @player.body.p.x = x * 16 + 8
    @player.body.p.y = y * 16 - 8
    @stage.space.add_matter(@player)
  end

  def destruct!
    @stage.space.remove_matter(@player)
    @enemies.each {|enemy| @stage.space.remove_matter(enemy) }.clear
    @stage.destruct!
    @current_proc = nil
    @parallel_procs.clear
  end

  def new_stage_from_file(file)
    Stage.create_from_struct(Asset.load_stage(file))
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

  def setup_stage_from_file(file)
    @stage = new_stage_from_file(file)
    @stage.target = @target
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

  def run_event(command, event)
    return run_parallel_event(command, event) if command.trigger == :every_update
    @current_proc = Interpreter.new(command, event)
  end

  def run_parallel_event(command, event)
    old = @parallel_procs.find_by(event_id: event.id)
    if old
      return if old.command_id == command.id
      @parallel_procs.delete(old)
    end
    @parallel_procs << Interpreter.new(command, event)
  end

  def update
    process_event

    @stage.update_event
    @stage.parallel_events.each(&:exec)
    return if event_running?

    @stage.update
    update_sprites

    exec_event
  end

  def event_running?
    current_proc_running? && parallel_procs_running?
  end

  def parallel_procs_running?
    @parallel_procs.any?(&:running?)
  end

  def current_proc_running?
    @current_proc && @current_proc.running?
  end

  def process_event
    @current_proc.update if current_proc_running?
    @parallel_procs.each(&:update)
    @parallel_procs.keep_if(&:running?)
  end

  def update_sprites
    @player.move(Input.x * 28, 0)
    @player.jump if (Input.key_push?(K_SPACE) or Input.key_push?(K_X))
    @player.update
    Sprite.update(@enemies)
  end

  def exec_event
    event = @stage.auto_events.first
    return event.exec if event
    if Input.key_push?(K_UP)
      event = @player.check(@stage.inspectable_events).first
      return event.exec if event
    end
    event = @player.check(@stage.touchable_events).first
    event.exec if event
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

Asset.load_image_db("image.yml")
game = Game.instance

Window.width = game.target.width * 2
Window.height = game.target.height * 2
Window.mag_filter = TEXF_POINT
Window.loop do
  game.update
  game.draw
end
