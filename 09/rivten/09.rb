content = ARGF
  .read
  .chomp
  .bytes
  .map{_1 - '0'.bytes[0]}
  .each_with_index
  .map{|x, idx| if idx % 2 == 0 then [x, idx / 2] else [x, :space] end}

# Part 1

#track = []
#content.each do |val, id|
#  val.times do track << id end
#end

#i = 0
#while i < track.length do
#  if track[i] == :space then
#    track[i] = track[track.length - 1]
#    track = track[...track.length - 1]
#    while track[track.length - 1] == :space do
#      track = track[...track.length - 1]
#    end
#  end
#  i += 1
#end
#
#p track.each_with_index.sum{|val, i| val * i}

# Part 2

i = content.length - 1
while i >= 0 do
  if content[i][1] != :space then
    for j in 0...i do
      if content[j][1] == :space && content[j][0] >= content[i][0] then
        first_space_search = j
        if content[j][0] == content[i][0] then
          old_i = content[i]
          content[j] = content[i]
          content[i] = [content[i][0], :space]
          
        else
          content.insert(j + 1, [content[j][0] - content[i][0], :space])
          i += 1
          old_i = content[i]
          content[j] = content[i]
          content[i] = [content[i][0], :space]
        end
        break
      end
    end
  end
  i -= 1
end

checksum = 0
pos = 0
content.each do |val, id|
  if id == :space then
    pos += val
  else
    val.times do
      checksum += id * pos
      pos += 1
    end
  end
end

p checksum
