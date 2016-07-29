module Geometric

  attr_accessor :geometry

  def min_x
    self.x - self.geometry.mid_x
  end

  def min_y
    self.y - self.geometry.mid_y
  end

  def max_x
    self.x + self.geometry.mid_x
  end

  def max_y
    self.x + self.geometry.mid_y
  end

end
