require_relative 'core'

module Qui

  class Component

    include Quincite::UI::Component

    attr_accessor :x, :y, :target
    attr_accessor :bg

    def initialize(id=:@anonymous, x=0, y=0)
      init_component
      self.id = id
      self.x = x
      self.y = y
    end

    def update_collision
    end

    def update
    end

    def draw
      return unless visible?
      target.draw(x, y, bg) if bg
    end

  end

end
