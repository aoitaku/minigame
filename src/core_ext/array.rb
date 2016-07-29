module QueriableArray

  refine Array do

    def find_by(hash)
      find {|_| hash.all? {|k, v| _.__send__(k) == v }}
    end

    def where(hash)
      select {|_| hash.all? {|k, v| _.__send__(k) == v }}
    end

  end
end
