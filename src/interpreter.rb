class Interpreter

  def initialize
    @variables = {}
    @switches  = {}
  end

  def run(script, event, object)
    instance_exec(event: event, object: object, &script)
  end

  def bgm(*args)
    p "play / pause / resume / change / stop bgm"
  end

  def se(*args)
    p "play se"
  end

  def bgs(*args)
    p "play / pause / resume / change / stop bgs"
  end

  def me(*args)
    p "play me"
  end

  def switch
    @switches
  end
  alias s switch

  def variable
    @variables
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
