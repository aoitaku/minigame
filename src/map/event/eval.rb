require_relative '../../core_ext/symbol'
require_relative 'metadata'

module Map

  using SymbolCaller

  class Event::Evaluator

    attr_reader :result

    def self.load(script)
      self.new {|loader| loader.instance_eval(script) }.result
    end

    def initialize
      @result = []
      yield(self)
    end

    def event(id)
      if block_given?
        @result << Event::Data[id, Event::Page::Evaluator.new(&:instance_exec&proc).result ]
      else
        @result << Event::Data[id]
      end
    end
  end

  class Event::Page::Evaluator

    attr_reader :result

    def initialize
      @result = []
      @image = nil
      yield(self)
    end

    def image(name, motion)
      @image = Event::ImageData[:image, name, motion]
      self
    end

    def on_check(in_case=true)
      raise ArgumentError unless block_given?
      @result << Event::Page[@result.size, @image, :on_check, in_case, :instance_exec&proc]
      @image = nil
    end

    def on_touch(in_case=true)
      raise ArgumentError unless block_given?
      @result << Event::Page[@result.size, @image, :on_touch, in_case, :instance_exec&proc]
      @image = nil
    end

    def on_ready(in_case=true)
      raise ArgumentError unless block_given?
      @result << Event::Page[@result.size, @image, :on_ready, in_case, :instance_exec&proc]
      @image = nil
    end

    def every_update(in_case=true)
      raise ArgumentError unless block_given?
      @result << Event::Page[@result.size, @image, :every_update, in_case, :instance_exec&proc]
      @image = nil
    end

    def do_nothing(in_case=true)
      @result << Event::Page[@result.size, @image, nil, in_case]
      @image = nil
    end

    def in_case
      raise ArgumentError unless block_given?
      :instance_exec&proc
    end

  end
end
