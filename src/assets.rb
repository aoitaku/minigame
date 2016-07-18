require 'tmx'
require_relative 'tmx/transform'

module Asset

  @dir = APP_DIR + 'asset'

  class << self
    attr_accessor :dir
  end

  def self.load_tmx(tmx_file)
    Tmx::Transform.new(Tmx.load(tmx_file)).apply
  end

  def self.chdir
    Dir.chdir(dir, &proc)
  end

end
