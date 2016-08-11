class Camera

  attr_accessor :x, :y, :dx, :dy, :max_x, :max_y

  def initialize(target, tile_size=16)
    @x = 0
    @y = 0
    @dx = nil
    @dy = nil
    @target = target
    @tile_size = tile_size
    @max_x = @target.width
    @max_y = @target.height
  end

  def update(x, y)
    case x
    when 0...(@target.width / 2 - @tile_size)
      @target.ox = 0
    when (@target.width / 2 - @tile_size)...(max_x - @target.width / 2 - @tile_size)
      @target.ox = x - (@target.width / 2 - @tile_size)
    when (max_x - @target.width / 2 - @tile_size)..max_x
      @target.ox = (max_x - @target.width / 2 - @tile_size)-(@target.width / 2 - @tile_size)
    end
  end

end
