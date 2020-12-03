module Main

isTree : Char -> Bool
isTree '#' = True
isTree '.' = False

treeInColumn : Nat -> String -> Bool
treeInColumn n line = isTree $ strIndex line $ toIntNat $ mod n $ length line

-- Not available in stdlib when zipping stream with a list
zipWith : (a -> b -> c) -> Stream a -> List b -> List c
zipWith f _ [] = []
zipWith f (x::xs) (y::ys) = f x y :: zipWith f xs ys

skips : Nat -> List a -> List a
skips k [] = []
skips k (x::xs) = x :: skips k (drop k $ x::xs)

checkSlope : List String -> (Nat, Nat) -> Nat
checkSlope input (x, y) = length $ filter id treesFound
  where treesFound = zipWith treeInColumn [0,x ..] $ skips y input

main : IO ()
main = do
    Right input <- readFile "input"
    let input = lines input
    printLn $ checkSlope input (3, 1)
    printLn $ product $ map (checkSlope input) [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
