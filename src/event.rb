require_relative 'core_ext/subscribable'
require_relative 'interpreter'
require_relative 'element'

class Event < Element

  class Data < Struct.new(:id, :pages, :stage_id, :x, :y, :width, :height)
  end

  class Page < Struct.new(:id, :image, :trigger, :condition, :command)
  end

  class ImageData < Struct.new(:image, :name, :motion)
    def to_a
      [image, name, motion]
    end
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
        @result << Data[id, Page::Evaluator.new {|event| event.instance_exec(&proc) }.result ]
      else
        @result << Data[id]
      end
    end
  end

  class Page::Evaluator

    attr_reader :result

    def initialize
      @result = []
      @image = nil
      yield(self)
    end

    def image(name, motion)
      @image = ImageData[:image, name, motion]
      self
    end

    def on_check(in_case=true)
      raise ArgumentError unless block_given?
      @result << Page[@result.size, @image, :on_check, in_case, -> event { event.instance_exec(&proc) }]
      @image = nil
    end

    def on_touch(in_case=true)
      raise ArgumentError unless block_given?
      @result << Page[@result.size, @image, :on_touch, in_case, -> event { event.instance_exec(&proc) }]
      @image = nil
    end

    def on_ready(in_case=true)
      raise ArgumentError unless block_given?
      @result << Page[@result.size, @image, :on_ready, in_case, -> event { event.instance_exec(&proc) }]
      @image = nil
    end

    def every_update(in_case=true)
      raise ArgumentError unless block_given?
      @result << Page[@result.size, @image, :every_update, in_case, -> event { event.instance_exec(&proc) }]
      @image = nil
    end

    def do_nothing(in_case=true)
      @result << Page[@result.size, @image, :every_update, in_case]
      @image = nil
    end

    def in_case
      raise ArgumentError unless block_given?
      -> event { event.instance_exec(&proc) }
    end

  end

  include Interpreter::Command

  include Subscribable

  attr_reader :id, :stage_id, :pages, :current_page

  def initialize(id, stage_id, x, y, geometry, pages=nil)
    super(x, y, geometry)
    @id = id
    @stage_id = stage_id
    @pages = pages.reverse || []
    @current_page = nil
    init_subscription
  end

  def trigger
    @current_page && @current_page.trigger
  end

  def exec
    schedule([@current_page, self])
  end

  def update
    @current_page = pages.find {|page| page.condition == true || page.condition.call(self) }
    self.image = @current_page.image
    publish_all
  end

  def to_sym
    @event_id ||= :"@#{stage_id}##{id}"
  end

  def self.create_from_struct(struct)
    self.new(
      struct.id,
      struct.stage_id,
      struct.x,
      struct.y,
      Physics::Rectangle.new(struct.width, struct.height),
      struct.pages.each {|page| page.image = Asset.load_image(*page.image.to_a) }
    )
  end

end
