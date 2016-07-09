require_relative 'physics'
require_relative 'stage/tileset'
require_relative 'stage/tilemap'
require_relative 'stage/collision'

class Stage

  class Data < Struct.new(:tilesets, :tilemaps, :collisions, :objects)

    def to_a
      [tilesets, tilemaps, collisions, objects]
    end

  end

  attr_accessor :target
  attr_reader :space, :tilemaps, :collisions, :objects

  def initialize(tilemaps, collisions, objects)
    @space = Physics::Space.new(1200)
    @tilemaps = tilemaps
    @collisions = collisions
    @collisions.each {|collision| @space.add_shape(collision.shape) }
    @objects = objects
  end

  def destruct!
    @collisions.each {|collision| @space.remove_shape(collision.shape) }.clear
  end

  def self.create_from_struct(struct)
    tileset = Tileset.create_from_structs(struct.tilesets)
    self.new(
      struct.tilemaps.map {|tilemap| Tilemap.new(tilemap, tileset)},
      struct.collisions.map {|collision| Collision.create_from_struct(collision)},
      struct.objects
    )
  end

  def update
    @space.update
  end

  def draw
    @tilemaps.each {|tilemap| tilemap.draw_to(target) }
  end

end
