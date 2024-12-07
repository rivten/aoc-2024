
equations = ARGF.each_line.map do |line|
  left, rights = line.split(":")
  left = left.to_i
  rights = rights.split(" ").map(&:to_i)
  [left, rights]
end

def possible_solve_rec target, elems, solution_count, current_val
  if elems.length == 0 then
    if current_val == target then
      return solution_count + 1
    else
      return solution_count
    end
  end

  x = elems[0]
  solution_count = possible_solve_rec(target, elems[1...], solution_count, current_val + x)
  possible_solve_rec(target, elems[1...], solution_count, current_val * x)
end

def possible_solve eq
  possible_solve_rec eq[0], eq[1], 0, 0
end

p equations.filter{|eq| possible_solve(eq) > 0}.sum{|eq| eq[0]}
