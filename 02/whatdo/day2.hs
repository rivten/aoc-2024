import Control.Monad
import Data.List
import System.IO

main = do
  contents <- readFile "day2.txt"
  let reports = map (map readInt) . map words . lines $ contents 
      safe = part1 reports
      in
      print safe
      
  
part1 :: [[Int]] -> Int
part1 = length . filter isOnlyAscendingOrDescendingWithMaxStep

data Direction = Ascending | Descending deriving (Eq)

direction :: (Int, Int) -> Direction
direction (a, b) = if a > b then Descending else Ascending

pairwise :: [a] -> [(a, a)]
pairwise [] = []
pairwise list@(x:xs) = zip list $ drop 1 list

allSame :: (Eq a) => [a] -> Bool
allSame = all tupleEquals . pairwise

tupleEquals :: (Eq a) => (a, a) -> Bool
tupleEquals (a, b) = a == b

isOnlyAscendingOrDescendingWithMaxStep :: [Int] -> Bool
isOnlyAscendingOrDescendingWithMaxStep [] = True
isOnlyAscendingOrDescendingWithMaxStep x = (allSame . map direction . pairwise $ x) && (all isSmallStep . pairwise $ x)

isSmallStep :: (Int, Int) -> Bool
isSmallStep (x, y) = let diff = abs (x - y) in diff >= 1 && diff <= 3

part2 :: ([Int], [Int]) -> Int
part2 (left, right) = sum $ map (\x -> x * (length $ filter (\xs -> x == xs) right)) left

split :: [Int] -> ([Int], [Int])
split [] = ([], [])
split (a:b:xs) = let (ax, bx) = split xs in (a:ax, b:bx)



readInt :: String -> Int
readInt = read
