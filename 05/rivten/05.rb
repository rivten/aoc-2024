def is_valid_update? rules, u
  rules.all? do |rule|
    a_idx = u.index rule[0]
    b_idx = u.index rule[1]

    a_idx.nil? || b_idx.nil? || a_idx < b_idx

  end
end

content = ARGF.read
rules, updates = content.split("\n\n")
rules = rules.split("\n").map{_1.split("|").map(&:to_i)}
updates = updates.split("\n").map{_1.split(",").map(&:to_i)}

p updates.filter{|u| is_valid_update? rules, u }.sum{|u| u[u.length / 2]}
