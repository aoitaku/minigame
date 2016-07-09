require 'tmx'
require_relative 'tmx/transform'

module Asset

  DIR = "#{APP_DIR}\\asset"

  def self.load_tmx(tmx_file)
    Tmx::Transform.new(Tmx.load(tmx_file)).apply
  end

end
