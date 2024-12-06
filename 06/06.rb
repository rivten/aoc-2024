require 'set'

content = ARGF.read.split("\n")

walls = Set.new

for i in 0...content.length do
  for j in 0...content[i].length do
    case content[i][j]
    when '#'
      walls.add [j, i]
    when '^'
      pos = [j, i]
    end
  end
end

def in_range? pos, content
  pos[0] >= 0 && pos[0] < content.length && pos[1] >= 0 && pos[1] < content[0].length
end

def turn_right dir
  case dir
  when [1, 0]
    [0, 1]
  when [0, 1]
    [-1, 0]
  when [-1, 0]
    [0, -1]
  when [0, -1]
    [1, 0]
  else
    raise "unknown dir #{dir}"
  end
end

dir = [0, -1]
been = Set.new
while in_range? pos, content do
  next_pos = [pos[0], pos[1]]
  next_pos[0] += dir[0]
  next_pos[1] += dir[1]

  if walls.include? next_pos then
    dir = turn_right dir
  else
    been.add pos
    pos = next_pos
  end
end

p been.length
