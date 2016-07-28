require_relative '../core_ext/array'

class Tmx::Transform

  using QueriableArray

  def initialize(tmx)
    @tmx = tmx
  end

  def apply
    Stage::Data[
      collect_tilesets,
      collect_tilemaps,
      collect_objects_by(name: "collision").map{|collision|
        Collision::Data.new(*collision)
      },
      collect_objects_by(name: "object")
    ]
  end

  def collect_tilesets
    @tmx.tilesets.where(name: "tileset").map(&method(:tileset_to_array))
  end

  def tileset_to_array(tileset)
    tile_size = tileset.tilewidth
    col_size = tileset.imagewidth / tile_size
    row_size = tileset.imageheight / tile_size
    Tileset::Data[tileset.image, col_size, row_size, tile_size]
  end

  def collect_tilemaps
    @tmx.layers.map(&method(:layer_to_table))
  end

  def layer_to_table(layer)
    layer.data.map(&method(:normalize_tile_id)).each_slice(layer.width).to_a
  end

  def normalize_tile_id(tile)
    tile.zero? ? nil : tile - 1
  end

  def collect_objects_by(hash)
    @tmx.object_groups.find_by(hash).objects.map(&method(:object_to_array))
  end

  def object_to_array(object)
    [
      object.type.to_sym,
      object.id,
      object.x,
      object.y,
      object.width,
      object.height,
      object.properties.map(&method(:normalize_property)).to_h
    ]
  end

  def normalize_property(args)
    property, values = args
    [property.to_sym, values.split(?,).map(&method(:deserialize))]
  end

  def deserialize(value)
    case value
    when /\A([1-9]\d*|0)\z/
      value.to_i
    when /\A([1-9]\d*|0)\.(\d+)\z/
      value.to_f
    else
      value.to_sym
    end
  end

end
