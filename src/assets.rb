require 'tmx'
require 'yaml'
require_relative 'tmx/transform'

module Asset

  @dir = APP_DIR + 'asset'

  class << self
    attr_accessor :dir
  end

  def self.load_tmx(tmx_file)
    Tmx::Transform.new(Tmx.load(tmx_file)).apply
  end

  def self.load_stage(stage_file)
    meta, *events = YAML.load_stream(File.read(stage_file), stage_file)
    tmx_file = Pathname.new(File.dirname(stage_file)) + (File.basename(stage_file, '.yml') + '.tmx')
    tmx = Tmx::Transform.new(Tmx.load(tmx_file)).apply
    tmx.meta = meta
    tmx.events = events.map {|event|
      event.map {|k, v| [k.to_sym, v]}.to_h
    }.map {|event|
      Event::Meta[
        event[:id],
        event[:trigger],
        event[:condition],
        event[:command]
      ]
    }
    tmx
  end

  def self.chdir
    Dir.chdir(dir, &proc)
  end

end
