class Slash < Sprite

  include Animative

  attr_accessor :power, :angle, :owner, :pattern

  def initialize(owner)
    super(0, 0)
    @owner = owner
    @count = 17
    @pattern = 0
    self.collision_enable = false
  end

  alias direction angle

  def attack_enemy(dest)
    Game.instance.chain
  end

  def die
    self.vanish
  end

  def update
    @count -= 1
    return if @count > 10
    if @count == 10
      self.collision_enable = true
      change_animation([
        [:attack_a_left, :attack_a_right],
        [:attack_c_left, :attack_c_right]
      ][self.pattern][self.angle])
      self.collision = [self.angle * 16 + 8, 16, 8]
    end
    self.die if @count == 0
    update_animation
    self.x = owner.x - self.image.width / 2
    self.y = owner.y - self.image.height / 2
  end

end
