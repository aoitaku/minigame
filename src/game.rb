require 'singleton'
require 'json'
require_relative 'function'
require_relative 'shader'
require_relative 'qui'
require_relative 'game/data'
require_relative 'player_controller'

class Game

  using QueriableArray

  include Singleton

  attr_reader :player
  attr_accessor :target, :variables, :switches

  def initialize
    @target = RenderTarget.new(256, 240)
    @ui_target = RenderTarget.new(256, 240)
    @shader = SpriteShader.new
    @screen_color = nil

    @enemies = []
    @bullets = []
    @switches  = Switch.new
    @variables = Variable.new
    @current_proc = nil
    @parallel_procs = []

    setup_stage_from_file(CONFIG.last_file)
    setup_player
    setup_event
    setup_ui
  end

  def setup_player
    _, _, x, y, width, height, properties = @stage.objects.find_by(first: :player)
    entry_player(new_character(:player, x, y + 8, width, height, properties, "player.json"))
  end

  def setup_ui
    Qui.setup(@ui_target.width, @ui_target.height)
    @ui = Qui.build {
      width  :full
      height :full
      Document {
        position :absolute
        width    :full
        height   64
        padding  8
        bottom   0
        Message(:message) {
          width   :full
          height  :full
          padding 8
          visible false
        }
      }
      Document {
        position :absolute
        width    0.5
        height   40
        padding  8
        top      0.5
        left     0.5
        Document(:menu) {
          width   :full
          height  :full
          padding [7, 8]
          visible false
          layout  :horizontal_box
        }
      }
    }
    @ui.components.each {|component| component.target = @ui_target }
    @ui.layout

    @theme = Asset.chdir { Image.load_tiles('window.png', 4, 4) }

    @message = @ui.find(:message)
    @message.bg = make_bg(@message.width, @message.height, @theme)

    @menu = @ui.find(:menu)
    @menu.bg = make_bg(@menu.width, @menu.height, @theme)
  end

  def make_bg(width, height, theme)
    RenderTarget.new(width, height).draw_tile(
      0,
      0,
      make_bg_patterns[width / 8, height / 8],
      theme,
      nil,
      nil,
      width / 8,
      height / 8
    ).to_image
  end

  def make_bg_patterns
    -> cols, rows {
      [
        [0, *([1, 2] * ((cols - 1) / 2))[0...(cols - 2)], 3],
        *([
          [4, *([5, 6] * ((cols - 1) / 2))[0...(cols - 2)], 7],
          [8, *([9, 10] * ((cols - 1) / 2))[0...(cols - 2)], 11]
        ] * ((rows - 1) / 2))[0...(rows - 2)],
        [12, *([13, 14] * ((cols - 1) / 2))[0...(cols - 2)], 15]
      ]
    }
  end

  def setup_event
    @stage.events.each do |event|
      event.subscribe -> args { run_event(*args) }
      event.target = @target
    end
  end

  def setup_stage_from_file(file)
    @stage = new_stage_from_file(file)
    @stage.target = @target
  end

  def entry_player(player)
    player.target = @target
    @stage.space.add_matter(player)
    PlayerController.attach(player)
    @player = player
  end

  def entry_enemy(enemy)
    enemy.target = @target
    @stage.space.add_matter(enemy)
    @enemies << enemy
  end

  def new_character(family, x, y, width, height, properties, image)
    Character.new(
      x,
      y,
      Physics::Rectangle.new(width, height),
      properties
    ) do |character|
      load_animation_to_character(image, character)
      character.family = family
    end
  end

  def new_interpreter(page, event)
    return Interpreter.new(event.id, page.id) unless page.command
    Interpreter.new(event.id, page.id) { page.command.call(event) }
  end

  def destruct!
    @stage.space.remove_matter(@player)
    @enemies.each {|enemy| @stage.space.remove_matter(enemy) }.clear
    @stage.destruct!
    @parallel_procs.clear
  end

  def reset_stage(id)
    destruct!
    setup_stage_from_file("#{id}.rb")
    setup_event
  end

  def reset_player(x, y)
    @player.body.p.x = x * 16 + 8
    @player.body.p.y = y * 16 - 8
    @player.sync_physics
    @stage.space.add_matter(@player)
  end

  def new_stage_from_file(file)
    Stage.create_from_struct(Asset.load_stage(file))
  end

  def update
    @ui.update if @ui.visible?
    process_event

    update_event
    return if event_running?

    @stage.update
    update_sprite

    exec_event
  end

  def update_player
    footholds = @player.landing(@stage.space)
    wall = @player.wall(@stage.space)
    if Input.key_push?(K_Z) and not PlayerController.attacking?
      @bullets << PlayerController.attack
    end
    if Input.x < 0
      @player.turn_left
    elsif Input.x > 0
      @player.turn_right
    end
    if @player.aerial?
      unless PlayerController.attacking?
        if @player.body.v.y > 0
          @player.start_falling
        else
          @player.start_waiting
        end
      end
      extend_jump = (Input.key_down?(K_SPACE) || Input.key_down?(K_X)) && @player.body.v.y < 0
      @player.move(wall ? 0 : Input.x * (PlayerController.attacking? ? 12 : 14), extend_jump ? -8 : 0)
    else
      unless PlayerController.attacking?
        if Input.x == 0
          @player.start_waiting
        else
          @player.start_walking
        end
      end
      start_jump = (Input.key_push?(K_SPACE) || Input.key_push?(K_X))
      if start_jump
        @player.jump
        @player.body.v.y = 0
      end
      @player.move(wall ? 0 : Input.x * (PlayerController.attacking? ? 4 : 28), start_jump ? -270 : 0)
    end
    @player.update
    PlayerController.update
  end

  def update_enemy
    @enemies.each do |enemy|
      enemy.landing(@stage.space)
      enemy.wall(@stage.space)
    end
    Sprite.update(@enemies)
  end

  def update_sprite
    update_player
    update_enemy
    Sprite.update(@bullets)
    Sprite.check(@bullets, @enemies, :attack_enemy, :hit_by_bullet)
    Sprite.check(@enemies, player, :shot, :hit_by_enemy)
    Sprite.clean(@bullets)
    Sprite.clean(@enemies)
  end

  def update_event
    @stage.update_event
    @stage.parallel_events.each(&:exec)
  end

  def run_event(page, event)
    return run_parallel_event(page, event) if page.trigger == :every_update
    @current_proc = new_interpreter(page, event)
  end

  def run_parallel_event(page, event)
    old = @parallel_procs.find_by(event_id: event.id)
    if old
      return if old.command_id == page.id
      @parallel_procs.delete(old)
    end
    @parallel_procs << new_interpreter(page, event)
  end

  def event_running?
    current_proc_running? || parallel_procs_running?
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

  def exec_event
    if Input.key_push?(K_C)
      @current_proc = Interpreter.new(:command, 0) do
        command_menu(
          [:key, "かぎ"],
          [:lighter, "ライター"]
        )
      end
      return
    end
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
    PlayerController.draw
    Sprite.draw(@enemies)
    Sprite.draw(@bullets)
    ex_params = { scale_x: 2, scale_y: 2 }
    if @screen_color
      @shader.color = @screen_color
      ex_params[:shader] = @shader
    end
    @ui.draw if @ui.visible?
    Window.draw_ex(
      @target.width / 2,
      @target.height / 2,
      @target,
      ex_params
    )
    Window.draw_ex(
      @ui_target.width / 2,
      @ui_target.height / 2,
      @ui_target,
      scale_x: 2,
      scale_y: 2
    ) if @ui.visible?
  end

  def message(text)
    @ui.style_set :visible, true
    @message.style_set :visible, true
    @message.text = text
    @ui.layout
    loop do
      break if Input.key_push?(K_Z) ||
        Input.key_push?(K_X) ||
        Input.key_push?(K_C)
      wait
    end
    wait
    @ui.style_set :visible, false
    @message.style_set :visible, false
  end

  def make_command_menu(commands)
    commands.map do |(id, name)|
      Qui.build {
        Message(:command) {
          width  0.5
          height :full
          color  [128, 128, 128]
        }
      }.find(:command).tap do |command|
        command.id     = id
        command.target = @ui_target
        command.text   = name || id.to_s
      end
    end
  end

  def command_menu(*commands)
    @ui.style_set :visible, true
    @menu.style_set :visible, true
    @menu_index = 0
    menu_commands = make_command_menu(commands).each do |command|
      @menu.add(command)
    end
    menu_commands[@menu_index].color = [255, 255, 255]
    @ui.layout
    loop do
      case
      when Input.key_push?(K_LEFT)
        menu_commands[@menu_index].color = [128, 128, 128]
        @menu_index = (@menu_index + 1).modulo(commands.size)
        menu_commands[@menu_index].color = [255, 255, 255]
        @ui.layout
      when Input.key_push?(K_RIGHT)
        menu_commands[@menu_index].color = [128, 128, 128]
        @menu_index = (@menu_index - 1).modulo(commands.size)
        menu_commands[@menu_index].color = [255, 255, 255]
        @ui.layout
      when Input.key_push?(K_Z)
        commands[@menu_index].first
      when Input.key_push?(K_X)
        break
      end
      wait
    end
    wait
    @ui.style_set :visible, false
    @menu.style_set :visible, false
    @menu.components.clear
  end

  def transport(id, x, y)
    screen_change([0, 0, 0, 0], [255, 0, 0, 0], 30)
    reset_stage(id)
    reset_player(x, y)
    screen_change([255, 0, 0, 0], [0, 0, 0, 0], 30)
    @screen_color = nil
  end

  def screen_change(from, to, duration)
    from_to = from.zip(to)
    step    = duration < 1 ? 1.0 : duration.to_f
    f       = Function.linear
    color   = -> n { from_to.map {|c1, c2| f[c1, c2, step, n] }}

    @screen_color = from
    duration.times do |n|
      @screen_color = color[n]
      wait
    end
    @screen_color = to
  end

  def wait(count=1)
    count.times { Fiber.yield }
  end

  def load_animation_to_character(filename, character)
    Game.load_animation_to_character(filename, character)
  end

  def self.load_animation_to_character(filename, character)
    data = JSON.parse(Asset.chdir { File.read(filename) }, symbolize_names: true)
    first = data[:frames].values.first
    meta = data[:meta]
    sprite_sheet = meta[:image]
    return unless Asset.chdir { File.exist?(sprite_sheet) }
    w, h = meta[:size][:w] / first[:sourceSize][:w], meta[:size][:h] / first[:sourceSize][:h]
    character.animation_image = Asset.chdir { Image.load_tiles(sprite_sheet, w, h) }
    meta[:frameTags].each do |frame|
      case frame[:direction]
      when 'forward'
        character.add_animation(frame[:name].to_sym, 6, [*frame[:from].to_i..frame[:to].to_i])
      when 'pingpong'
        character.add_animation(frame[:name].to_sym, 6, [
          *frame[:from].to_i...frame[:to].to_i,
          *((frame[:from].to_i + 1)..frame[:to].to_i).to_a.reverse
        ])
      end
    end
    character.image = character.animation_image.first
  end

  def chain
  end

end
