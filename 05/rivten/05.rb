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

p updates
  .filter{|u| is_valid_update? rules, u }
  .sum{|u| u[u.length / 2]}

graph = {}

rules.each do |r|
  graph[r[0]] = [] if graph[r[0]].nil?
  graph[r[0]] << r[1]
end

def fix_update graph, u
  fixed = []
  u.each do |x|
    insertion_pos = fixed.length
    fixed[0...insertion_pos].each_with_index do |before, before_idx|
      if graph[x].include? before then
        insertion_pos = before_idx
        break
      end
    end
    fixed.insert(insertion_pos, x)
  end
  fixed
end

p updates
  .filter{|u| !is_valid_update? rules, u}
  .map{|u| fix_update graph, u}
  .sum{|u| u[u.length / 2]}

