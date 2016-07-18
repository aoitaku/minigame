require_relative '../core_ext/delegable'

module Physics

  class MetaData < Struct.new(:move_from, :on)
  end

  class Model

    extend Delegable

    attr_accessor :body, :shape

    delegate_to :body,
      :p        => :position,
      :v        => :velocity,
      :f        => :force,
      :f=       => :force=,
      :a        => :angle,
      :a=       => :angle=,
      :w        => :rot_speed,
      :w=       => :rot_speed=,
      :t        => :torque,
      :t=       => :torque=,
      :rot      => :rotation,
      :rot=     => :rotation=,
      :v_limit  => :max_speed,
      :v_limit= => :max_speed=,
      :w_limit  => :max_rot_speed,
      :w_limit= => :max_rot_speed=,
      :object   => :meta_data

    delegate_to :position,
      :x,
      :y,
      :x=,
      :y=

    delegate_to :velocity,
      :x  => :vx,
      :x= => :vx=,
      :y  => :vy,
      :y= => :vy=

    delegate_to :meta_data,
      :move_from,
      :move_from=,
      :on,
      :on=

    delegate_to :shape,
      :group,
      :group=,
      :layers,
      :layers=,
      :collision_type,
      :collision_type=,
      :e          => :elasticity,
      :e=         => :elasticity=,
      :u          => :friction,
      :u=         => :friction=,
      :surface_v  => :surface_velocity,
      :surface_v= => :surface_velocity=

    def initialize(x, y, mass, moment)
      @body = Physics.body(x, y, mass, moment)
      @body.object = MetaData.new
    end

    def init_shape_from_box(x, y, width, height)
      @shape = Physics.box_shape(@body, x, y, width, height)
    end

    def init_shape_from_circle(x, y, r)
      @shape = Physics.circle_shape(@body, x, y, r)
    end

    def add_to_space(space)
      space.add_matter(self)
    end

  end
end
