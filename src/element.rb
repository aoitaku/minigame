require 'dxruby'
require_relative 'geometric'

class Element < Sprite

  include Geometric

  def initialize(x, y, geometry, image=nil)
    super(x, y, image)
    @geometry = geometry
  end

  def image=(image)
    super
    if image
      self.offset_sync = true
      self.center_x = image.width / 2
      self.center_y = image.height - geometry.height / 2
      self.collision = [
        (image.width - geometry.width) / 2,
        image.height - geometry.height,
        (image.width - geometry.width) / 2 + geometry.width,
        image.height
      ]
    else
      self.offset_sync = false
      self.collision = geometry.to_a
    end
  end

end
