content = ARGF.read.split("\n")

antennas = Hash.new {|h,k| h[k] = []}

width = content[0].length
height = content.length

height.times do |y|
  width.times do |x|
    if content[y][x] != "." then
      # a position is a complex number x + yi
      antennas[content[y][x]] << x + y * 1i
    end
  end
end

def in_range? antinode, width, height
  x = antinode.real
  y = antinode.imaginary
  x >= 0 && x < width && y >= 0 && y < height
end

antinodes = Set.new

antennas.each do |a, positions|
  positions.combination(2).each do |a0, a1|
    d = a1 - a0
    k = 0
    while in_range? (a0 + k * d), width, height do
      antinodes.add (a0 + k * d)
      k += 1
    end
    k = -1
    while in_range? (a0 + k * d), width, height do
      antinodes.add (a0 + k * d)
      k -= 1
    end
  end
end

p antinodes.length
