class Enemy

  module DB
    def self.find(id)

      case id
      when :pumpkin_head
        {
          family: :enemy,
          image: 'enemy001.json',
          geometry: Physics::Rectangle.new(16, 16),
          properties: [],
          initializer: -> enemy {
            enemy.set_action {
              loop do
                (120 + rand(60)-30).times { Fiber.yield }
                turn
                wait
              end
            }
            enemy.set_handler(:fall) {
              wait
            }
            enemy.set_handler(:land) {
              if alive?
                walk
              else
                wait
              end
            }
            enemy.set_handler(:wall) {
              turn
              if alive?
                walk
              else
                wait
              end
            }
            enemy.set_handler(:dead) {
              wait
            }
          }
        }
      end

    end
  end

end
