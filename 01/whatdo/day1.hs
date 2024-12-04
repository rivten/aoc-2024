import Control.Monad
import Data.List
import System.IO

main = do
  contents <- readFile "day1.txt"
  let numbers = map readInt . words $ contents
      splitted = split numbers 
      summed = part1 splitted 
      equalScore = part2 splitted in

      print equalScore
      
  
part1 :: ([Int], [Int]) -> Int
part1 (a, b) = sum $ map abs (zipWith (-) (sort a) (sort b))

part2 :: ([Int], [Int]) -> Int
part2 (left, right) = foldl (\acc x -> acc + x * (length (filter (\xs -> x == xs) right))) 0 left

split :: [Int] -> ([Int], [Int])
split [] = ([], [])
split (a:b:xs) = let (ax, bx) = split xs in (a:ax, b:bx)



readInt :: String -> Int
readInt = read
