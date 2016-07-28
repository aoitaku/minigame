require 'forwardable'

module Physics

  class Space

    GRANULARITY = 4
    RESOLUTION = 1.0 / (60 * [GRANULARITY, 1].max)

    extend Forwardable

    def_delegators :@space, :add_shape, :add_body, :remove_shape, :remove_body
    def_delegators :@space, :segment_query_first

    def initialize(gravity_volume)
      @space = CP::Space.new
      @space.gravity = vec2(0, gravity_volume)
    end

    def self.static_body
      @static_body ||= CP::Body.new_static
    end

    def add_matter(matter)
      add_body(matter.body)
      add_shape(matter.shape)
    end

    def remove_matter(matter)
      remove_body(matter.body)
      remove_shape(matter.shape)
    end

    def add_collision_handler(a, b, handler=Proc.new)
      @space.add_collision_handler(a, b, &handler)
    end

    def gravity_volume=(gravity_volume)
      @space.gravity.y = gravity_volume
    end

    def update
      granularity_for_update.times { @space.step(resolution_for_update) }
    end

    def granularity_for_update
      GRANULARITY
    end
    private :granularity_for_update

    def resolution_for_update
      RESOLUTION
    end
    private :resolution_for_update

  end
end
