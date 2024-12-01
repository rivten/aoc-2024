lefts = []
rights = []
ARGF.each_line do |line|
  left, right = line.match(/^(\d+)\s+(\d+)\n$/).captures
  lefts << left.to_i
  rights << right.to_i
end

# Part 1
lefts = lefts.sort
rights = rights.sort
p lefts.zip(rights).map{|x| (x[0] - x[1]).abs}.sum

# Part 2
def similarity_score x, rights
  rights.filter {|y| y == x}.length
end

p lefts.map{|x| x * similarity_score(x, rights)}.sum
