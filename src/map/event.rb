require_relative '../core_ext/subscribable'
require_relative '../interpreter'
require_relative '../element'

class Map::Event < Element

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
    @current_page = pages.find {|page| page.condition == true || page.condition.(self) }
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
