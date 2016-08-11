require 'tmx'
require 'yaml'
require_relative 'tmx/transform'
require_relative 'interpreter'

module Asset

  using QueriableArray

  @dir = ASSET_DIR
  @images = {}

  class << self
    attr_accessor :dir
  end

  def self.load_tmx(tmx_file)
    Tmx::Transform.new(Asset.chdir { Tmx.load(tmx_file) }).apply
  end

  def self.load_stage(stage_file)
    events = Map::Event::Evaluator.load(Asset.chdir { File.read(stage_file) })
    stage_name = File.basename(stage_file, '.rb')
    tmx_file = Pathname.new(File.dirname(stage_file)) + (stage_name + '.tmx')
    load_tmx(tmx_file).tap do |stage|
      stage.events = stage.objects.where(first: :event).map do |_, id, x, y, width, height, _|
        (events.find_by(id: id) || Map::Event::Data[id]).tap do |event|
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

  def self.load_image_db(db_file)
    image_db = Asset.chdir { YAML.load_file(db_file)}
    image_name = File.basename(db_file, '.yml')
    image_file = Pathname.new(File.dirname(db_file)) + (image_name + '.png')
    images = Asset.chdir { Image.load_tiles(image_file.to_s, 8, 2)}
    @images[image_name.to_sym] = Hash[image_db.map {|image_data|
      name, motions = image_data["name"], image_data["motions"]
      if motions
        [name.to_sym, Hash[motions.map {|motion|
          [motion.to_sym, images.shift]
        }]]
      else
        [name.to_sym, images.shift]
      end
    }]
  end

  def self.load_image(image_name, name, motion=nil)
    if motion
      @images[image_name][name][motion]
    else
      @images[image_name][name]
    end
  end

end
