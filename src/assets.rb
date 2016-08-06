require 'tmx'
require 'yaml'
require_relative 'tmx/transform'
require_relative 'interpreter'

module Asset

  using QueriableArray

  @dir = APP_DIR + 'asset'

  class << self
    attr_accessor :dir
  end

  def self.load_tmx(tmx_file)
    Tmx::Transform.new(Tmx.load(tmx_file)).apply
  end

  def self.load_stage(stage_file)
    events = Event::Evaluator.load(File.read(stage_file))
    stage_name = File.basename(stage_file, '.rb')
    tmx_file = Pathname.new(File.dirname(stage_file)) + (stage_name + '.tmx')
    Tmx::Transform.new(Tmx.load(tmx_file)).apply.tap do |stage|
      stage.events = stage.objects.where(first: :event).map do |_, id, x, y, width, height, _|
        (events.find_by(id: id) || Event::Data[id]).tap do |event|
          event.stage_id = stage_name.to_sym
          event.x = x
          event.y = y
          event.width = width
          event.height = height
        end
      end
    end
  end

  def self.chdir
    Dir.chdir(dir, &proc)
  end

end
