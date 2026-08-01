-- | FSOT trinary substrate T = {-1, 0, +1}. Twin of Zig @src/trit.zig@.
module Fsot.Trit
  ( Trit
  , asTrit
  , negT
  , pair
  , sumSat
  , consensus
  , basePrimary
  , codonPrimary
  ) where

type Trit = Int -- -1 | 0 | +1

asTrit :: Int -> Trit
asTrit x
  | x > 0 = 1
  | x < 0 = -1
  | otherwise = 0

negT :: Trit -> Trit
negT t = asTrit (-t)

pair :: Trit -> Trit -> Trit
pair a b = asTrit (a * b)

sumSat :: Trit -> Trit -> Trit
sumSat a b = asTrit (a + b)

consensus :: Trit -> Trit -> Trit
consensus a b = if a == b then a else 0

-- | A,G → +1; C,T → −1
basePrimary :: Char -> Trit
basePrimary b = case b of
  'A' -> 1
  'a' -> 1
  'G' -> 1
  'g' -> 1
  'C' -> -1
  'c' -> -1
  'T' -> -1
  't' -> -1
  'U' -> -1
  'u' -> -1
  _ -> 0

codonPrimary :: Char -> Char -> Char -> (Trit, Trit, Trit)
codonPrimary c0 c1 c2 = (basePrimary c0, basePrimary c1, basePrimary c2)
