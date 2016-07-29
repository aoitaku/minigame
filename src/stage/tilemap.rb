class Tilemap

  extend Forwardable

  attr_accessor :tiles, :tileset

  def_delegator :tiles,   :size,  :row_size
  def_delegator :tiles,   :first, :cols
  def_delegator :cols,    :size,  :col_size

  def initialize(tiles, tileset)
    @tiles   = tiles
    @tileset = tileset
  end

  def draw_to(target)
    target.draw_tile(0, 0, tiles, tileset.image, 0, 0, col_size, row_size)
  end

end
