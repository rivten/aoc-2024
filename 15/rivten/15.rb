map, moves = ARGF.read.chomp.split("\n\n")
map = map.split("\n")
moves = moves.tr("\n", "")

HEIGHT = map.length
WIDTH = map[0].length

m = {}
for y in 0...HEIGHT do
  for x in 0...WIDTH do
    if map[y][x] == "#" then
      m[x + y * 1i] = :wall
    elsif map[y][x] == "O" then
      m[x + y * 1i] = :rock
    elsif map[y][x] == "@" then
      r = x + y * 1i
    end
  end
end

def move m, r, d
  valid = true
  k = 1
  rocks_seen = []
  while true do
    x = m[r + k * d]
    case x
    when nil
      break
    when :wall
      valid = false
      break
    when :rock
      rocks_seen << r + k * d
    else
      raise "unknown map content"
    end
    k += 1
  end

  if valid then
    rocks_seen.reverse.each do |rock|
      m.delete(rock)
      m[rock + d] = :rock
    end
    r += d
  end
  return [m, r]
end

def draw m, r
  for y in 0...HEIGHT do
    line = ""
    for x in 0...WIDTH do
      c = x + y * 1i
      if r == c then
        line += "@"
      elsif m[c] == :wall then
        line += "#"
      elsif m[c] == :rock then
        line += "O"
      else
        line += "."
      end
    end
    puts line
  end
end

moves.each_char do |c|
  case c
  when "<"
    m, r = move m, r, -1
  when ">"
    m, r = move m, r, 1
  when "^"
    m, r = move m, r, -1i
  when "v"
    m, r = move m, r, 1i
  end
end

p m.each.sum{|c, v| v == :rock ? c.real + 100 * c.imaginary : 0}
