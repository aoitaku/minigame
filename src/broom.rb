require_relative 'weapon'
require_relative 'slash'

class Broom < Weapon

  def initialize(owner)
    super
    Game.load_animation_to_character("weapon.json", self)
    @power = 1
  end

  def shot(angle, pattern)
    @shoot_count = 20
    start_animation([
      [:broom_a_left, :broom_a_right],
      [:broom_c_left, :broom_c_right]
    ][pattern][angle])
    self.target = owner.target
    Slash.new(owner).tap do |bullet|
      Game.instance.load_animation_to_character("effects.json", bullet)
      bullet.target = owner.target
      bullet.power = self.power
      bullet.angle = angle
      bullet.pattern = pattern
    end
  end

  def update
    super
    if @shoot_count > 0
      update_animation
      self.x = owner.x - self.image.width / 2
      self.y = owner.y - self.image.height / 2
    end
  end

end
