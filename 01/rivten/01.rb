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
p lefts.zip(rights).sum{(_1 - _2).abs}

# Part 2
def similarity_score x, rights
  x * rights.filter{|y| y == x}.length
end

p lefts.sum{similarity_score(_1, rights)}
