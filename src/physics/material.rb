module Physics

  class Material

    attr_reader :elasticity, :friction

    def initialize(elasticity, friction)
      @elasticity = elasticity
      @friction = friction
    end

  end
end
