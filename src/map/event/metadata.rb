module Map

  class Event::Data < Struct.new(:id, :pages, :stage_id, :x, :y, :width, :height)
  end

  class Event::Page < Struct.new(:id, :image, :trigger, :condition, :command)
  end

  class Event::ImageData < Struct.new(:image, :name, :motion)
    def to_a
      [image, name, motion]
    end
  end

end
