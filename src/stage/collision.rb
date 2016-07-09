class Collision

  class Data < Struct.new(:type, :x, :y, :width, :height)

    def to_a
      [type, x, y, width, height]
    end

  end

  attr_accessor :type
  attr_reader :body, :shape

  def initialize(type, x, y, width, height)
    @body  = Physics.static_body(x + width / 2, y + height / 2)
    @shape = Physics.box_shape(@body, 0, 0, width, height)
    @shape.e = Physics::ELASTICFUL
    @shape.u = Physics::FRICTIONLESS
    @shape.group = 1
    @shape.collision_type = 1
    @shape.layers = 0b11111111
    @type = type
  end

  def self.create_from_struct(struct)
    self.new(*struct.to_a)
  end

end
