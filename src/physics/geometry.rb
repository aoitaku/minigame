require_relative 'core'

module Physics

  class Geometry

    def to_body(mass, moment=nil)
      moment ||= self.moment
      Physics.body(mass, moment)
    end

  end

end
