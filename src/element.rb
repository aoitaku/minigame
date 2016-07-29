require 'dxruby'
require_relative 'geometric'

class Element < Sprite

  include Geometric

  def initialize(x, y, geometry, image=nil)
    super(x, y, image)
    @geometry = geometry
    if image
      self.offset_sync = true
      self.center_x = geometry.mid_x
      self.center_y = geometry.mid_y
    end
    self.collision = geometry.to_a
  end

end
