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
player_image = Dir.chdir(Asset::DIR) do
  Image.load("player.png")
end
player = Character.new(*player_source, player_image)
player.family = family
player.target = target

stage.space.add_matter(player.model)

enemies = stage.objects.where(first: :enemy).map do |family, *enemy_source|
  enemy_image = Dir.chdir(Asset::DIR) do
    Image.load("enemy.png")
  end
  Character.new(*enemy_source, enemy_image).tap do |enemy|
    enemy.family = family
    enemy.target = target
    stage.space.add_matter(enemy.model)
  end
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
