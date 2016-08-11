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

    def command_menu(commands)
      game.command_menu(commands)
    end

    def message(text)
      game.message(text)
    end

    def transport(id, x:, y:)
      game.transport(id, x, y)
    end

  end

  attr_reader :event_id, :page_id

  def initialize(event_id, page_id)
    @fiber = Fiber.new(&proc) if block_given?
    @event_id = event_id
    @page_id = page_id
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
