require_relative 'core_ext/subscribable'
require_relative 'interpreter'
require_relative 'element'

class Event < Element

  class Data < Struct.new(:id, :commands, :stage_id, :x, :y, :width, :height)
  end

  class Command < Struct.new(:id, :trigger, :condition, :command)
  end

  class Evaluator

    attr_reader :result

    def self.load(script)
      self.new {|loader| loader.instance_eval(script) }.result
    end

    def initialize
      @result = []
      yield(self)
    end

    def event(id)
      if block_given?
        @result << Data[id, Command::Evaluator.new {|event| event.instance_exec(&proc) }.result ]
      else
        @result << Data[id]
      end
    end
  end

  class Command::Evaluator

    attr_reader :result

    def initialize
      @result = []
      yield(self)
    end

    def on_check(in_case=true)
      raise ArgumentError unless block_given?
      @result << Command[@result.size, :on_check, in_case, -> event { event.instance_exec(&proc) }]
    end

    def on_touch(in_case=true)
      raise ArgumentError unless block_given?
      @result << Command[@result.size, :on_touch, in_case, -> event { event.instance_exec(&proc) }]
    end

    def on_ready(in_case=true)
      raise ArgumentError unless block_given?
      @result << Command[@result.size, :on_ready, in_case, -> event { event.instance_exec(&proc) }]
    end

    def every_update(in_case=true)
      raise ArgumentError unless block_given?
      @result << Command[@result.size, :every_update, in_case, -> event { event.instance_exec(&proc) }]
    end

    def in_case
      raise ArgumentError unless block_given?
      -> event { event.instance_exec(&proc) }
    end
  end

  include Interpreter::Command

  include Subscribable

  attr_reader :id, :stage_id, :commands

  def initialize(id, stage_id, x, y, geometry, commands=nil, image=nil)
    super(x, y, geometry)
    @id = id
    @stage_id = stage_id
    @commands = commands || []
    init_subscription
  end

  def current_command
    @command ||= commands.find {|command| command.condition == true || command.condition.call(self) }
  end

  def command
    current_command
  end

  def trigger
    current_command && current_command.trigger
  end

  def exec(*)
    schedule([command, self])
  end

  def update
    @command = nil
    publish_all
  end

  def self.create_from_struct(struct)
    self.new(
      struct.id,
      struct.stage_id,
      struct.x,
      struct.y,
      Physics::Rectangle.new(struct.width, struct.height),
      struct.commands
    )
  end

end
