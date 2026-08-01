-- | Seed-scaled fixed-point — continuous FSOT values without IEEE float ops.
--
-- Twin of Zig @src/fixed.zig@:
--   Type: Integer storage, Integer intermediate for mul/div.
--   SCALE = 10^12.
module Fsot.Fixed
  ( Fixed
  , scale
  , fromInt
  , fromRatio
  , fromDecimalStr
  , toDouble
  , fromDoubleLab
  , add
  , sub
  , mul
  , divF
  , neg
  , clamp
  , lt
  , gt
  , absF
  ) where

import Data.Char (isDigit)

-- | Fixed-point value: integer × (1/SCALE).
type Fixed = Integer

scale :: Integer
scale = 1000000000000 -- 10^12

fromInt :: Integer -> Fixed
fromInt n = n * scale

fromRatio :: Integer -> Integer -> Fixed
fromRatio _ 0 = 0
fromRatio num den =
  let wide = num * scale
      (q, r) = wide `quotRem` den
      ad = abs den
      ar = abs r
   in if ar * 2 >= ad
        then if (wide > 0) == (den > 0) then q + 1 else q - 1
        else q

-- | Decimal string with optional leading minus (seed load path).
fromDecimalStr :: String -> Fixed
fromDecimalStr s0 =
  let (negS, s) = case s0 of
        ('-' : rest) -> (True, rest)
        _ -> (False, s0)
      (intPart, fracRest) = break (== '.') s
      intN = readDigits intPart
      fracDigits =
        case fracRest of
          ('.' : fs) ->
            let digs = take 12 (filter isDigit fs)
                n = length digs
                padded = digs ++ replicate (12 - n) '0'
             in readDigits padded
          _ -> 0
      v = intN * scale + fracDigits
   in if negS then -v else v
  where
    readDigits xs =
      case filter isDigit xs of
        [] -> 0
        ds -> read ds

toDouble :: Fixed -> Double
toDouble x = fromIntegral x / fromIntegral scale

-- | Lab bridge only (Allen polish / report). Mind authority stays Fixed.
fromDoubleLab :: Double -> Fixed
fromDoubleLab x = round (x * fromIntegral scale)

add :: Fixed -> Fixed -> Fixed
add = (+)

sub :: Fixed -> Fixed -> Fixed
sub = (-)

mul :: Fixed -> Fixed -> Fixed
mul a b =
  let wide = a * b
      (q, r) = wide `quotRem` scale
      ar = abs r
   in if ar * 2 >= scale
        then if (wide > 0) then q + 1 else q - 1
        else q

divF :: Fixed -> Fixed -> Fixed
divF _ 0 = 0
divF a b =
  let wide = a * scale
      (q, r) = wide `quotRem` b
      ad = abs b
      ar = abs r
   in if ar * 2 >= ad
        then if (wide > 0) == (b > 0) then q + 1 else q - 1
        else q

neg :: Fixed -> Fixed
neg = negate

clamp :: Fixed -> Fixed -> Fixed -> Fixed
clamp x lo hi
  | x < lo = lo
  | x > hi = hi
  | otherwise = x

lt :: Fixed -> Fixed -> Bool
lt = (<)

gt :: Fixed -> Fixed -> Bool
gt = (>)

absF :: Fixed -> Fixed
absF = abs
