f = -> value {
  case value
  when /\A([1-9]\d*|0)\z/
    value.to_i
  when /\A([1-9]\d*|0)\.(\d+)\z/
    value.to_f
  else
    value.to_sym
  end
}


p f.call "0"
p f.call "1"
p f.call "100"
p f.call "0.1"
p f.call "0.01"
p f.call "1.0"
p f.call "100.0"
p f.call "10.10.10"
