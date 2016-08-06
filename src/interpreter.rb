require 'fiber'

class Interpreter

  module Command

    def game
      Game.instance
    end
    private :game

    def bgm(*args)
    end

    def se(*args)
    end

    def bgs(*args)
    end

    def me(*args)
    end

    def switch
      game.switches
    end
    alias s switch

    def variable
      game.variables
    end
    alias v variable

    def item(*args)
      p "pop item"
    end

    def enemy(*args)
      p "pop enemy"
    end

    def effect(*args)
      p "pop effect"
    end

    def message(*args)
      p "show / hide message"
    end

    def transport(*args)
      p "transport player to another place"
    end

  end

  attr_reader :event_id, :command_id

  def initialize(command, event)
    @fiber = Fiber.new { command.command.call(event) }
    @event_id = event_id
    @command_id = command.id
  end

  def update
    return unless @fiber
    cancel if @fiber.resume
  end

  def running?
    @fiber && @fiber.alive?
  end

  def cancel
    @fiber = nil
  end

end
