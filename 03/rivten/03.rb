content = ARGF.read
enabled = true
res = 0
start_index = 0

while true do
  if enabled then
    end_index = content[start_index...].index("don't()")
    if end_index.nil?
      # everything up until the end is enabled
      res += content[start_index...].scan(/mul\((\d+),(\d+)\)/).sum{_1.to_i * _2.to_i}
      break
    end
    res += content[start_index...(start_index + end_index)].scan(/mul\((\d+),(\d+)\)/).sum{_1.to_i * _2.to_i}
    start_index += end_index + 7
    enabled = false
  else
    end_index = content[start_index...].index("do()")
    if end_index.nil?
      # nothing more is enabled
      break
    end
    start_index += end_index + 4
    enabled = true
  end
end
p res
