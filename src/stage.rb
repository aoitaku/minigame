require_relative 'physics'
require_relative 'map'
require_relative 'interpreter'

class Stage

  using QueriableArray

  class Data < Struct.new(:tilesets, :tilemaps, :collisions, :objects, :events, :meta)
  end

  attr_accessor :target
  attr_reader :space, :tilemaps, :collisions, :objects, :events, :meta

  def initialize(tilemaps, collisions, objects, events, meta)
    @space = Physics::Space.new(1200)
    @tilemaps = tilemaps
    @collisions = collisions
    @collisions.each {|collision| @space.add_shape(collision.shape) }
    @objects = objects
    @events = events
    @meta = meta
  end

  def destruct!
    @collisions.each {|collision| @space.remove_shape(collision.shape) }.clear
  end

  def self.create_from_struct(struct)
    tileset = Map::Tileset.create_from_structs(struct.tilesets)
    self.new(
      struct.tilemaps.map {|tilemap| Map::Tilemap.new(tilemap, tileset)},
      struct.collisions.map {|collision| Map::Collision.create_from_struct(collision)},
      struct.objects,
      struct.events.map {|event| Map::Event.create_from_struct(event)},
      struct.meta
    )
  end

  def update
    @space.update
  end

  def update_event
    Sprite.update(@events)
    @active_events = nil
  end

  def draw
    @tilemaps.each {|tilemap| tilemap.draw_to(target) }
    Sprite.draw(@events)
  end

  def active_events
    @active_events ||= @events.select(&:current_page)
  end

  def touchable_events
    active_events.where(trigger: :on_touch)
  end

  def inspectable_events
    active_events.where(trigger: :on_check)
  end

  def auto_events
    active_events.where(trigger: :on_ready)
  end

  def parallel_events
    active_events.where(trigger: :every_update)
  end

end
