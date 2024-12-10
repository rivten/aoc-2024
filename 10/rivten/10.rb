require 'set'

map = ARGF
  .read
  .chomp
  .split("\n")
  .map {|line| line.bytes.map{_1 - ?0.ord}}

width = map[0].length
height = map.length

trailhead_positions = []
for y in 0...height do
  for x in 0...width do
    if map[y][x] == 0 then
      trailhead_positions << x + y * 1i
    end
  end
end

DIRS = [
  1 + 0i,
  -1 + 0i,
  0 + 1i,
  0 - 1i
]

def in_range? p, map
  p.real >= 0 && p.real < map[0].length && p.imaginary >= 0 && p.imaginary < map.length
end

def score p, map
  stack = [[p, 0]]
  finishes = Set.new
  count = 0
  while !stack.empty? do
    pos, h = stack.pop
    if h == 9 then
      finishes.add pos
      count += 1
      next
    end
    for d in DIRS do
      pos_test = pos + d
      if !in_range? pos_test, map then
        next
      end
      h_test = map[pos_test.imaginary][pos_test.real]
      if h_test == h + 1 then
        stack << [pos_test, h_test]
      end
    end
  end
  [finishes.length, count]
end

p trailhead_positions.sum{score(_1, map)[0]}
p trailhead_positions.sum{score(_1, map)[1]}
