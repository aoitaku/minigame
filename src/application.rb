require 'chipmunk'
require 'forwardable'

require_relative 'stage'
require_relative 'character'
require_relative 'assets'

using QueriableArray

stage = Stage.create_from_struct(Asset.load_tmx(CONFIG.last_file))
target = RenderTarget.new(256, 240)
stage.target = target

family, *player_source = stage.objects.find_by(first: :player)
player = Character.new(*player_source, Asset.chdir{ Image.load("player.png") }) do |player|
  player.family = family
  player.target = target
  stage.space.add_matter(player.model)
end

enemies = stage.objects.where(first: :enemy).map do |family, *enemy_source|
  Character.new(*enemy_source, Asset.chdir{ Image.load("enemy.png") }) do |enemy|
    enemy.family = family
    enemy.target = target
    stage.space.add_matter(enemy.model)
  end
end

stage.space.add_collision_handler :character, :conveyor, -> a, b, arbiter do
  if a.body.p.y > b.body.p.y
    a.u = Physics::FRICTIONLESS
    b.u = Physics::FRICTIONLESS
    b.surface_v = vec2(0, 0)
    return true
  end
  a.u = 0.4
  b.u = 1.0
  b.surface_v = vec2(-1000, 0)
end

Window.width = target.width * 2
Window.height = target.height * 2
Window.mag_filter = TEXF_POINT
Window.loop do
  stage.update
  player.move(
    Input.x * 16,
    (Input.key_push?(K_SPACE) or Input.key_push?(K_X)) ? player.jump : 0
  )
  player.update
  Sprite.update(enemies)
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
