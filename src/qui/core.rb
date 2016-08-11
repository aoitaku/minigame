require 'quincite'
require 'dxruby'

module Qui

  include Quincite

  def self.setup(width, height)
    UI.max_width = width
    UI.max_height = height
  end

  def self.build
    raise unless block_given?
    UI.build(UI::Document, &proc)
  end

  def self.update(components)
    Sprite.update(components)
  end

  def self.draw(components)
    Sprite.draw(components)
  end

end
