class Quincite::UI::Document < Qui::Container

  include Quincite::UI::Layouter

  def initialize(*args)
    super
    self.style_set :layout,          :vertical_box
    self.style_set :justify_content, :left
    self.style_set :align_items,     :top
  end

end
