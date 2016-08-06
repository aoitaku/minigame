event 52 do
  on_check do
    transport 1, x: 3, y: 10
  end
end

event 53 do
  on_check in_case {
    switch[self] != true
  } do
    enemy :pumpkin, x: 12, y: 10
    variable[self] = 120
    switch[self] = true
  end

  every_update in_case {
    switch[self] == true
  } do
    variable[self] -= 1
    if variable[self] == 0
      switch[self] = false
    end
  end
end
