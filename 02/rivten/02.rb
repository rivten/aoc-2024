
def is_line_valid line
  numbers = line.split.map(&:to_i)
  diffs = numbers.each_cons(2).map{_2 - _1}
  (diffs.all?(&:positive?) || diffs.all?(&:negative?)) && diffs.all?{_1.abs >= 1 && _1.abs <= 3}
end

p ARGF.each_line.count(&method(:is_line_valid))
