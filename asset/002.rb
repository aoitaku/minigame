event 52 do
  image(:switch, :off).on_check do
    switch[0] = true
  end

  image(:switch, :on).on_check in_case {
    switch[0] == true
  } do
    switch[0] = false
  end
end

event 53 do
  image(:door, :close).do_nothing

  image(:door, :open).on_check in_case {
    switch[0] == true
  } do
    transport "001", x: 10, y: 13
  end
end

event 55 do
  image(:chest, :close).on_check do
    switch[1] = true
  end

  image(:chest, :open).do_nothing in_case {
    switch[1] == true
  }
end
