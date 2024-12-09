content = ARGF
  .read
  .chomp
  .bytes
  .map{_1 - '0'.bytes[0]}
  .each_with_index
  .map{|x, idx| if idx % 2 == 0 then [x, idx / 2] else [x, :space] end}

track = []
content.each do |val, id|
  val.times do track << id end
end

i = 0
while i < track.length do
  if track[i] == :space then
    track[i] = track[track.length - 1]
    track = track[...track.length - 1]
    while track[track.length - 1] == :space do
      track = track[...track.length - 1]
    end
  end
  i += 1
end

p track.each_with_index.sum{|val, i| val * i}
