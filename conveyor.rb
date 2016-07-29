stage.space.add_collision_handler :character, :conveyor, -> a, b, arbiter do
  if a.body.p.y > b.body.p.y
    a.u = Physics::FRICTIONLESS
    b.u = Physics::FRICTIONLESS
    b.surface_v = vec2(0, 0)
    return true
  end
  a.u = 0.4
  b.u = 1.0
  b.surface_v = vec2(-1000, 0)
end
