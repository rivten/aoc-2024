import Control.Monad
import Data.List
import System.IO

main = do
  contents <- readFile "day2.txt"
  let reports = map (map readInt) . map words . lines $ contents 
      safe = part1 reports
      safeDampener = part2 reports
      in
      print safeDampener
      
  
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

isOnlyAscendingOrDescendingWithMaxStepWith1ErrorMax :: [Int] -> Bool
isOnlyAscendingOrDescendingWithMaxStepWith1ErrorMax x = any isOnlyAscendingOrDescendingWithMaxStep $ map removeElement $ zip (iterate (+1) 0) (replicate (length x) x)

removeElement :: (Int, [a]) -> [a]
removeElement (idx, l) 
  | idx < 0 = l 
  | otherwise = splitL ++ (drop 1 splitR)
  where 
    (splitL, splitR) = splitAt idx l

isSmallStep :: (Int, Int) -> Bool
isSmallStep (x, y) = let diff = abs (x - y) in diff >= 1 && diff <= 3

part2 :: [[Int]] -> Int
part2 = length . filter isOnlyAscendingOrDescendingWithMaxStepWith1ErrorMax

readInt :: String -> Int
readInt = read
