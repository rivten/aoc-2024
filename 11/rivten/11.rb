stones = ARGF.read.split.map(&:to_i)

def digit_count s
  if s == 0
    return 1
  end

  c = 0
  while s != 0 do
    c += 1
    s /= 10
  end
  c
end

def digit_left s
  dcount = digit_count s
  s / 10**(dcount/2)
end

def digit_right s
  dcount = digit_count s
  p = 10**(dcount/2)
  s - ((s / p) * p)
end

def blink stones
  next_stones = []
  stones.each do |s|
    if s == 0 then
      next_stones << 1
    elsif digit_count(s).even? then
      next_stones << digit_left(s)
      next_stones << digit_right(s)
    else
      next_stones << s * 2024
    end
  end
  next_stones
end

$cache = {}

def expand_count stone, count
  if count == 0 then
    1
  elsif $cache.key? [stone, count] then
    $cache[[stone, count]]
  else
    next_stones = blink [stone]
    r = next_stones.sum{|s| expand_count s, (count - 1)}
    $cache[[stone, count]] = r
    r
  end
end

p stones.sum{|s| expand_count s, 75}
