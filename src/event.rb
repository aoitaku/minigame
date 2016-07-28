require_relative 'core_ext/subscribable'

class Event < Sprite

  class Meta < Struct.new(:id, :trigger, :condition, :command)
  end

  include Subscribable

  attr_accessor :width, :height
  attr_reader :trigger, :command, :subscriptions

  def initialize(x, y, width, height, properties, meta)
    super(x, y)
    self.collision = [width / 2.0, height - width / 2.0, width / 2.0]
    @width = width
    @height = height
    if meta
      @trigger = meta[:trigger].to_sym
      @condition = meta[:condition]
      @command = eval(%(-> **args { #{meta[:command]} }))
    end
    init_subscription
  end

  def exec(object)
    schedule([command, self, object])
  end

  def update
    publish_all
  end

end
