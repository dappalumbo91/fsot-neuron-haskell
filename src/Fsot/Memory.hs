-- | Episodic memory store (twin of Zig memory_fixed.zig — host simplified).
module Fsot.Memory
  ( Store (..)
  , emptyStore
  , hashToken
  , encode
  , retrieve
  , RetrieveHit (..)
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Data.Bits (xor, shiftL)
import Data.Char (ord)
import Data.List (maximumBy)
import Data.Ord (comparing)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/memory_fixed.zig"

data Engram = Engram
  { eCue :: Int
  , eAns :: Int
  , eCueTxt :: String
  , eAnsTxt :: String
  , eStrength :: Double
  }
  deriving (Show)

data Store = Store
  { sEngrams :: [Engram]
  , sN :: Int
  }
  deriving (Show)

emptyStore :: Store
emptyStore = Store [] 0

-- | FNV-ish token hash (stable across hosts).
hashToken :: String -> Int
hashToken s = foldl step 2166136261 s `mod` 2147483647
  where
    step h c = (h `xor` ord c) * 16777619

encode :: Store -> String -> String -> Store
encode st cue ans =
  let e =
        Engram
          { eCue = hashToken cue
          , eAns = hashToken ans
          , eCueTxt = cue
          , eAnsTxt = ans
          , eStrength = 1.0
          }
   in st {sEngrams = e : take 511 (sEngrams st), sN = min 512 (sN st + 1)}

data RetrieveHit = RetrieveHit
  { rAns :: String
  , rScore :: Double
  , rOk :: Bool
  }
  deriving (Show)

retrieve :: Store -> String -> RetrieveHit
retrieve st cue =
  let qh = hashToken cue
      scored =
        [ (e, if eCue e == qh then eStrength e else 0.15 * eStrength e * overlap (eCueTxt e) cue)
        | e <- sEngrams st
        ]
   in case filter ((> 0.05) . snd) scored of
        [] -> RetrieveHit "" 0 False
        xs ->
          let (best, sc) = maximumBy (comparing snd) xs
           in RetrieveHit (eAnsTxt best) sc True

overlap :: String -> String -> Double
overlap a b =
  let wa = words a
      wb = words b
      n = length [w | w <- wa, w `elem` wb]
   in if null wa then 0 else fromIntegral n / fromIntegral (length wa)

selfTest :: Bool
selfTest =
  let st0 = emptyStore
      st1 = encode st0 "one and one" "two"
      st2 = encode st1 "plants need" "sun"
      h = retrieve st2 "one and one"
   in rOk h && rAns h == "two"
