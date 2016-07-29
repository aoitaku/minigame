require_relative '../assets'

class Tileset

  class Data < Struct.new(:image, :col_size, :row_size, :tile_size)

    def to_a
      [image, col_size, row_size, tile_size]
    end

  end

  attr_accessor :image

  def initialize(image)
    @image = image
  end

  def self.create_from_struct(struct)
    self.new(Image.load_tiles(*struct.to_a))
  end

  def self.create_from_structs(structs)
   self.new(structs.flat_map {|struct| Asset.chdir { Image.load_tiles(*struct.to_a) } })
  end

end
