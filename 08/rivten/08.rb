content = ARGF.read.split("\n")

antennas = Hash.new {|h,k| h[k] = []}

width = content[0].length
height = content.length

height.times do |y|
  width.times do |x|
    if content[y][x] != "." then
      antennas[content[y][x]] << x + y * 1i
    end
  end
end

def get_antinodes a0, a1
  d = a1 - a0
  [a0 + 2 * d, a1 - 2 * d]
end

def in_range? antinode, width, height
  x = antinode.real
  y = antinode.imaginary
  x >= 0 && x < width && y >= 0 && y < height
end

antinodes = Set.new

antennas.each do |a, positions|
  positions.combination(2).each do |a0, a1|
    anti0, anti1 = get_antinodes a0, a1
    antinodes.add anti0 if in_range? anti0, width, height
    antinodes.add anti1 if in_range? anti1, width, height
  end
end

p antinodes.length
