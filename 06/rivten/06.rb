require 'set'

content = ARGF.read.split("\n")

walls = Set.new

for y in 0...content.length do
  for x in 0...content[y].length do
    case content[y][x]
    when '#'
      walls.add [x, y]
    when '^'
      pos = [x, y]
      start_pos = [x, y]
    end
  end
end

def in_range? pos, w, h
  pos[0] >= 0 && pos[0] < w && pos[1] >= 0 && pos[1] < h
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
been_with_dir = Set.new
while in_range? pos, content[0].length, content.length do
  next_pos = [pos[0], pos[1]]
  next_pos[0] += dir[0]
  next_pos[1] += dir[1]

  if walls.include? next_pos then
    dir = turn_right dir
  else
    been.add pos
    been_with_dir.add [pos, dir]
    pos = next_pos
  end
end

p been.length

# part 2

p2_possible_positions = Set.new
been_with_dir.each do |pos, dir|
  p2_possible_positions.add [pos[0] + dir[0], pos[1] + dir[1]]
end

h = content.length
w = content[0].length

def wall_create_loop? walls, w, h, start_pos, x, y
  been = Set.new
  new_walls = Set.new
  walls.each { |wall| new_walls.add wall }
  new_walls.add [x, y]

  pos = start_pos
  dir = [0, -1]
  while true do
    next_pos = [pos[0], pos[1]]
    next_pos[0] += dir[0]
    next_pos[1] += dir[1]

    if new_walls.include? next_pos then
      dir = turn_right dir
    else
      pos = next_pos

      if !in_range? pos, w, h then
        return false
      end

      if been.include? [pos, dir] then
        return true
      end

      been.add [pos, dir]
    end
  end
end


wall_position_count = 0
p2_possible_positions.each do |x, y|
  if walls.include? [x, y] then
    next
  end
  if start_pos[0] == x && start_pos[1] == y then
    next
  end

  if wall_create_loop? walls, w, h, start_pos, x, y then
    wall_position_count += 1
  end
end


p wall_position_count
