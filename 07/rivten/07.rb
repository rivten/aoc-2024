
equations = ARGF.each_line.map do |line|
  left, rights = line.split(":")
  left = left.to_i
  rights = rights.split(" ").map(&:to_i)
  [left, rights]
end

def concat x, y
  # i know, i'm cheating :D
  (x.to_s + y.to_s).to_i
end

def possible_solve_rec target, elems, solution_count, current_val
  if elems.length == 0 then
    if current_val == target then
      return solution_count + 1
    else
      return solution_count
    end
  end

  if current_val > target then
    # main optim
    # it works because all operations strictly increase the value
    return solution_count
  end

  x = elems[0]
  solution_count = possible_solve_rec(target, elems[1...], solution_count, current_val + x)
  solution_count = possible_solve_rec(target, elems[1...], solution_count, current_val * x)
  possible_solve_rec(target, elems[1...], solution_count, concat(current_val, x))
end

def possible_solve eq
  possible_solve_rec eq[0], eq[1], 0, 0
end

p equations.filter{|eq| possible_solve(eq) > 0}.sum{|eq| eq[0]}
