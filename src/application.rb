require 'chipmunk'
require 'forwardable'
require_relative 'stage'
require_relative 'character'
require_relative 'assets'
require_relative 'game'

Asset.load_image_db("image.yml")
Asset.chdir { Font.install("KonatuTohaba.ttf") }
Font.default = Font.new(10, "小夏 等幅")

game = Game.instance

Window.width = game.target.width * 2
Window.height = game.target.height * 2

Window.mag_filter = TEXF_POINT
Window.loop do
  game.update
  game.draw
end
