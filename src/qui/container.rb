require_relative 'core'
require_relative 'component'

module Qui

  class Container < Component

    include Quincite::UI::Container

    def initialize(*args)
      super
      init_container
    end

    def draw
      super
      Qui.draw(components) if visible?
    end

    def update
      super
      Qui.update(components)
    end

    def target=(target)
      components.each {|component| component.target = target }
      super
    end

  end
end
