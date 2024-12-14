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

def draw robots
  for y in 0...HEIGHT do
    line = ""
    for x in 0...WIDTH do
      count = robots.count{|r| r[:p] == x + y * 1i}
      if count == 0 then
        line += "."
      else
        line += count.to_s
      end
    end
    puts line
  end
end

analysis = false
if analysis then
  require 'csv'
  CSV.open("out.csv", "wb") do |csv|
    100000.times do |sec|
      robots.each do |r|
        advance r
      end
      q1 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
      q2 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}
      q3 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
      q4 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}
      q = q1 * q2 * q3 * q4

      csv << [sec, q1 * q2 * q3 * q4]

      ## gnuplot script used to see the csv and determine the rare data
      #
      # set datafile separator ","
      # plot 'out.csv' using 1:2
      #
    end
  end
else
  100000.times do |sec|
    robots.each do |r|
      advance r
    end
    q1 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
    q2 = robots.count{|r| r[:p].real < (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}
    q3 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary < (HEIGHT / 2)}
    q4 = robots.count{|r| r[:p].real > (WIDTH / 2) && r[:p].imaginary > (HEIGHT / 2)}
    q = q1 * q2 * q3 * q4


    # determined by analysis
    threshold = 50000000
    if q <  threshold then
      p sec + 1
      draw robots
      break
    end
  end
end


