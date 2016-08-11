module Function

  def self.linear(max=255, min=0)
    -> t1, t2, step, n do
      case
      when t2 > t1
        [(t2 - t1) / step * n, max].min
      when t1 > t2
        [t1 - (t1 - t2) / step * n, min].max
      else
        t1
      end
    end
  end

end
