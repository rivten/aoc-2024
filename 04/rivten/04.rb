content = ARGF.read.split("\n")

DIRS = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1]
]

# part 1
def in_range? content, t
  raise "non-squared content" unless content.length == content[0].length
  t >= 0 && t < content.length
end

XMAS = "XMAS"
def is_xmas_at? content, i, j, d
  (0...XMAS.length).map do |t|
    ti = i + t * d[0]
    tj = j + t * d[1]
    in_range?(content, ti) && in_range?(content, tj) && content[ti][tj] == XMAS[t]
  end.all?
end

count = 0

for i in 0...content.length do
  for j in 0...content[0].length do
    DIRS.each do |d|
      if is_xmas_at?(content, i, j, d) then
        count += 1
      end
    end
  end
end

p count

# part 2
def is_x_mas_at? content, i, j
  if content[i][j] != "A" then
    return false
  end
  top_left = content[i - 1][j - 1]
  top_right = content[i - 1][j + 1]
  bot_left = content[i + 1][j - 1]
  bot_right = content[i + 1][j + 1]
  letters = [top_left, top_right, bot_left, bot_right]
  if !letters.all?{_1 == "M" || _1 == "S"} then
    return false
  end
  if letters.group_by(&:itself).transform_values!(&:size).values.max != 2 then
    return false
  end
  if top_left == bot_right then
    return false
  end
  return true
end

count = 0
for i in 1...content.length - 1 do
  for j in 1...content[i].length - 1 do
    if is_x_mas_at? content, i, j then
      count += 1
    end
  end
end
p count
