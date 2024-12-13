content = ARGF.read.chomp.split("\n\n").map{_1.split "\n"}

machines = content.map do |paragraph|
  b_a = paragraph[0].scan(/X\+(\d+), Y\+(\d+)/)[0].map(&:to_i)
  b_b = paragraph[1].scan(/X\+(\d+), Y\+(\d+)/)[0].map(&:to_i)
  prize = paragraph[2].scan(/X=(\d+), Y=(\d+)/)[0].map(&:to_i)
  {a: b_a, b: b_b, prize: prize.map{|x| x + 10000000000000}}
end

p (machines.map do |m|
  ax = m[:a][0]
  ay = m[:a][1]
  bx = m[:b][0]
  by = m[:b][1]
  px = m[:prize][0]
  py = m[:prize][1]

  # matrix
  # ( ax  bx ) (a) = (px)
  # ( ay  by ) (b) = (py)

  invdet = ax * by - ay * bx
  if invdet == 0 then
    nil
  else
    if (by * px - bx * py) % invdet == 0 && (- ay * px + ax * py) % invdet == 0 then
      a = (by * px - bx * py) / invdet
      b = (- ay * px + ax * py) / invdet
      a > 0 && b > 0 ? 3 * a + b : nil
    else
      nil
    end
  end
end).filter{|x| !x.nil?}.sum
