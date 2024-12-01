lefts = []
rights = []
ARGF.each_line do |line|
  left, right = line.match(/^(\d+)\s+(\d+)\n$/).captures
  lefts << left.to_i
  rights << right.to_i
end

lefts = lefts.sort
rights = rights.sort
p lefts.zip(rights).map{|x| (x[0] - x[1]).abs}.sum
