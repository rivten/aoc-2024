content = ARGF.read
p content.scan(/mul\((\d+),(\d+)\)/).sum{_1.to_i * _2.to_i}
