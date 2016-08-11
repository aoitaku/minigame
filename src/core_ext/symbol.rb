module SymbolCaller

  refine Symbol do

    def call(*argv)
      case
      when block_given?
        -> obj { self.to_proc.call(obj, *argv, &proc) }
      when argv.size > 0
        -> obj { self.to_proc.call(obj, *argv) }
      else
        self.to_proc
      end
    end

    def &(callable)
      call(&callable)
    end

  end

end
