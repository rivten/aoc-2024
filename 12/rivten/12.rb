require 'set'

map = ARGF.read.chomp.split("\n")

DIRS = [-1, 1, -1i, 1i]

def in_range? test_p, map
  x = test_p.real
  y = test_p.imaginary
  x >= 0 && x < map[0].length && y >= 0 && y < map.length
end

def get_region map, start_p
  # basic flood fill
  type = map[start_p.imaginary][start_p.real]
  stack = [start_p]
  region = Set.new
  region.add start_p
  while !stack.empty? do
    p = stack.pop
    for d in DIRS do
      test_p = p + d
      if !region.include?(test_p) && in_range?(test_p, map) && map[test_p.imaginary][test_p.real] == type then
        region.add test_p
        stack << test_p
      end
    end
  end
  region
end

regions = []
considered = Set.new
for y in 0...map.length do
  for x in 0...map[y].length do
    p = x + y * 1i
    if !considered.include? p then
      region = get_region map, p
      for p in region do
        considered.add p
      end
      regions << region
    end
  end
end

def perimeter region
  region.sum do |p|
    DIRS.sum {|d| region.include?(p + d) ? 0 : 1}
  end
end

def price region
  region.length * perimeter(region)
end

p regions.sum{|r| price r}
