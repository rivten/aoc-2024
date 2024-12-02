
def valid? diffs
  (diffs.all?(&:positive?) || diffs.all?(&:negative?)) && diffs.all?{_1.abs >= 1 && _1.abs <= 3}
end

def is_line_valid? line
  numbers = line.split.map(&:to_i)
  diffs = numbers.each_cons(2).map{_2 - _1}
  valid? diffs
end

def is_line_almost_valid? line
  if is_line_valid? line
    return true
  end
  numbers = line.split.map(&:to_i)
  for i in 0..numbers.length do
    almost_numbers = numbers.clone
    almost_numbers.delete_at i
    almost_diffs = almost_numbers.each_cons(2).map{_2 - _1}
    if valid? almost_diffs
      return true
    end
  end
  return false
end

lines = ARGF.each_line.to_a
p lines.count(&method(:is_line_valid?))
p lines.count(&method(:is_line_almost_valid?))
