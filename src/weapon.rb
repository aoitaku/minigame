class Weapon < Sprite

  include Animative

  attr_reader :power, :range, :distance, :collision, :shoot_count, :owner

  def initialize(owner)
    super(owner.x, owner.y)
    @shoot_count = 0
    @owner = owner
  end

  def shootable?
    shooting? == false
  end

  def shooting?
    @shoot_count > 0
  end

  def update
    @shoot_count -= 1 if shooting?
  end
end
