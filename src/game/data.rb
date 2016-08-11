class Game

  class Switch

    def initialize
      @global_data = {}
      @event_data = {}
    end

    def []=(key, value)
      case key
      when Map::Event
        @event_data[key.to_sym] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Map::Event
        @event_data[key.to_sym]
      else
        @global_data[key]
      end
    end
  end

  class Variable

    def initialize
      @global_data = {}
      @event_data = {}
    end

    def []=(key, value)
      case key
      when Event
        @event_data[key.to_sym] = value
      else
        @global_data[key] = value
      end
    end

    def [](key)
      case key
      when Event
        @event_data[key.to_sym]
      else
        @global_data[key]
      end
    end

  end
end
