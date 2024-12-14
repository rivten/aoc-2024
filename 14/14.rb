robots = ARGF
  .read
  .chomp
  .split("\n")
  .map{_1.scan(/^p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)$/)[0].map(&:to_i)}
  .map{|px, py, vx, vy| {p: px + py * 1i, v: vx + vy * 1i}}

WIDTH = 101
HEIGHT = 103

def advance r
  r[:p] += r[:v]
  r[:p] = (r[:p].real % WIDTH) + (r[:p].imaginary % HEIGHT) * 1i
end

100.times do 
  robots.each do |r|
    advance r
  end
end

q1 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
q2 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}
q3 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
q4 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}

p q1 * q2 * q3 * q4
