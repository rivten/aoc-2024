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
    DIRS.count {|d| !region.include?(p + d)}
  end
end

def price region
  region.length * perimeter(region)
end

def fences region
  fences = []
  region.each do |p|
    DIRS.filter{|d| !region.include?(p + d)}.each do |d|
      fences << [p, d]
    end
  end
  fences
end

def build_fence_graph fences
  g = Hash.new {|h, k| h[k] = []}
  fences.each do |f|
    p, d = f
    if d.real == 0 then
      # horizontal bar
      g[f] = fences.filter{|op, od| od.real == 0 && (od - d).imaginary == 0 && (op - p).real.abs == 1 && (op - p).imaginary == 0}
    elsif d.imaginary == 0 then
      # vertical bar
      g[f] = fences.filter{|op, od| od.imaginary == 0 && (od - d).real == 0 && (op - p).imaginary.abs == 1 && (op - p).real == 0}
    else
      raise "impossible"
    end
  end
  g
end

def graph_connex_count g
  visited = Set.new
  count = 0
  for start_fence, adj_fences in g do
    next if visited.include? start_fence
    count += 1
    stack = [start_fence]
    while !stack.empty? do
      f = stack.pop
      next if visited.include? f
      visited.add f
      for adj_f in g[f] do
        stack << adj_f
      end
    end
  end
  count
end

def bulk_price region
  region.length * graph_connex_count(build_fence_graph(fences region))
end

p regions.sum{|r| price r}
p regions.sum{|r| bulk_price r}
