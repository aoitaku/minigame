require_relative 'broom'

module PlayerController

  @attack_flip = 0

  def self.attach(player)
    @weapon = Broom.new(player)
  end

  def self.player
    Game.instance.player
  end

   def self.attacking?
    @attacking and @attacking.alive?
  end

  def self.attacked
    @attacking = false
    player.start_animation([
      [:wait_left, :wait_right],
      [:fall_left, :fall_right]
    ][player.aerial? ? 1 : 0][player.direction]) unless player.damaging?
  end

  def self.update
    @weapon.update
    @attacking.resume if attacking?
  end

  def self.draw
    @weapon.draw if attacking?
  end

  def self.attack
    player.start_animation([
      [:attack_a_left, :attack_a_right],
      [:attack_c_left, :attack_c_right]
    ][@attack_flip][player.direction])
    @attacking = Fiber.new {
      3.times { Fiber.yield }
      player.collision_enable = false unless player.damaging?
      6.times { Fiber.yield }
      player.collision_enable = true unless player.damaging?
      12.times { Fiber.yield }
      self.attacked
    }
    @weapon.shot(player.direction, @attack_flip).tap do
      @attack_flip = @attack_flip == 0 ? 1 : 0
    end
  end

end
