require 'chipmunk'
require 'forwardable'

require_relative 'stage'
require_relative 'character'
require_relative 'event'
require_relative 'assets'
require_relative 'interpreter'

using QueriableArray

stage = Stage.create_from_struct(Asset.load_stage(CONFIG.last_file))
target = RenderTarget.new(256, 240)
stage.target = target

family, id, *player_source, width, height, properties = stage.objects.find_by(first: :player)
player = Character.new(*player_source, Physics::Rectangle.new(width, height), properties, Asset.chdir{ Image.load("player.png") }) do |player|
  player.family = family
  player.target = target
  stage.space.add_matter(player)
end

enemies = stage.objects.where(first: :enemy).map do |family, id, *enemy_source|
  Character.new(*enemy_source, Asset.chdir{ Image.load("enemy.png") }) do |enemy|
    enemy.family = family
    enemy.target = target
    stage.space.add_matter(enemy)
  end
end

interpreter = Interpreter.new

events = stage.objects.where(first: :event).map do |_, id, x, y, width, height, _|
  event = Event.new(
    x,
    y,
    Physics::Rectangle.new(width, height),
    stage.events.find_by(id: id)
  )
  event.subscribe -> args { interpreter.run *args }
  event
end

Window.width = target.width * 2
Window.height = target.height * 2
Window.mag_filter = TEXF_POINT
Window.loop do
  stage.update
  player.move(Input.x * 28, 0)
  player.jump if (Input.key_push?(K_SPACE) or Input.key_push?(K_X))
  player.update
  Sprite.update(enemies)
  Sprite.update(events)
  Sprite.check(events.where(trigger: :hit), player, :exec)
  event = player.check(events.where(trigger: :find)).first
  if event && Input.key_push?(K_UP)
    event.exec(player)
  end
  stage.draw
  player.draw
  Sprite.draw(enemies)
  Window.draw_scale(
    target.width / 2,
    target.height / 2,
    target,
    2,
    2
  )
end
