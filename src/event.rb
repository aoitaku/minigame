require_relative 'core_ext/subscribable'
require_relative 'element'

class Event < Element

  class Meta < Struct.new(:id, :trigger, :condition, :command)
  end

  include Subscribable

  attr_reader :trigger, :command, :subscriptions

  def initialize(x, y, geometry, meta, image=nil)
    super(x, y, geometry)
    if meta
      @trigger   = meta[:trigger].to_sym
      @condition = eval(%(-> **args { #{meta[:condition]} })) if meta[:condition]
      @command   = eval(%(-> **args { #{meta[:command]}   })) if meta[:command]
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
