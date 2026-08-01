-- | FSOT 64-codon trinary foundation.
-- Twin of Zig @src/codon.zig@ + data/64_codon_trinary_map.txt.
--
-- PRIMARY: A,G → +1 ; C,T → −1
-- SECONDARY: A=+1, T=−1, G/C=0
-- DNA codon → IUPAC AA → charge / aromatic for gene programs.
module Fsot.Codon
  ( Residue (..)
  , primaryTrip
  , secondaryBase
  , secondaryTrip
  , dnaToAa
  , aaCharge
  , aaIsAromatic
  , decodeOrf
  , geneExpression
  , meanSpin
  , chargeBalance
  , aromaticFraction
  , selfTest
  ) where

import Data.Char (toUpper)
import Fsot.Seeds (gamma, phi, seedPi)
import Fsot.Trit (Trit, basePrimary, codonPrimary)

data Residue = Residue
  { resC0 :: Char
  , resC1 :: Char
  , resC2 :: Char
  , resTrip :: (Trit, Trit, Trit)
  , resAa :: Char
  }
  deriving (Eq, Show)

primaryTrip :: Char -> Char -> Char -> (Trit, Trit, Trit)
primaryTrip = codonPrimary

secondaryBase :: Char -> Trit
secondaryBase b = case toUpper b of
  'A' -> 1
  'T' -> -1
  'U' -> -1
  'G' -> 0
  'C' -> 0
  _ -> 0

secondaryTrip :: Char -> Char -> Char -> (Trit, Trit, Trit)
secondaryTrip c0 c1 c2 = (secondaryBase c0, secondaryBase c1, secondaryBase c2)

upperBase :: Char -> Char
upperBase b = case b of
  'u' -> 'T'
  'U' -> 'T'
  _ -> toUpper b

dnaToAa :: Char -> Char -> Char -> Char
dnaToAa c0 c1 c2 =
  let a = upperBase c0
      b = upperBase c1
      c = upperBase c2
   in case a of
        'T' -> case b of
          'T' -> case c of
            'T' -> 'F'
            'C' -> 'F'
            'A' -> 'L'
            'G' -> 'L'
            _ -> '?'
          'C' -> 'S'
          'A' -> case c of
            'T' -> 'Y'
            'C' -> 'Y'
            'A' -> '*'
            'G' -> '*'
            _ -> '?'
          'G' -> case c of
            'T' -> 'C'
            'C' -> 'C'
            'A' -> '*'
            'G' -> 'W'
            _ -> '?'
          _ -> '?'
        'C' -> case b of
          'T' -> 'L'
          'C' -> 'P'
          'A' -> case c of
            'T' -> 'H'
            'C' -> 'H'
            'A' -> 'Q'
            'G' -> 'Q'
            _ -> '?'
          'G' -> 'R'
          _ -> '?'
        'A' -> case b of
          'T' -> case c of
            'T' -> 'I'
            'C' -> 'I'
            'A' -> 'I'
            'G' -> 'M'
            _ -> '?'
          'C' -> 'T'
          'A' -> case c of
            'T' -> 'N'
            'C' -> 'N'
            'A' -> 'K'
            'G' -> 'K'
            _ -> '?'
          'G' -> case c of
            'T' -> 'S'
            'C' -> 'S'
            'A' -> 'R'
            'G' -> 'R'
            _ -> '?'
          _ -> '?'
        'G' -> case b of
          'T' -> 'V'
          'C' -> 'A'
          'A' -> case c of
            'T' -> 'D'
            'C' -> 'D'
            'A' -> 'E'
            'G' -> 'E'
            _ -> '?'
          'G' -> 'G'
          _ -> '?'
        _ -> '?'

aaCharge :: Char -> Int
aaCharge aa = case aa of
  'R' -> 1
  'H' -> 1
  'K' -> 1
  'D' -> -1
  'E' -> -1
  _ -> 0

aaIsAromatic :: Char -> Bool
aaIsAromatic aa = aa `elem` ['F', 'Y', 'W']

-- | Decode DNA ORF (length multiple of 3) → residues with PRIMARY trinary.
decodeOrf :: String -> [Residue]
decodeOrf dna = go (filter (`elem` "ACGTacgtUTu") dna)
  where
    go (x : y : z : rest) =
      let a = upperBase x
          b = upperBase y
          c = upperBase z
       in Residue a b c (primaryTrip a b c) (dnaToAa a b c) : go rest
    go _ = []

meanSpin :: [Residue] -> Double
meanSpin [] = 0
meanSpin rs =
  let trips = map resTrip rs
      s = sum [fromIntegral (t0 + t1 + t2) | (t0, t1, t2) <- trips]
      n = fromIntegral (3 * length rs)
   in s / n

chargeBalance :: [Residue] -> Int
chargeBalance = sum . map (aaCharge . resAa)

aromaticFraction :: [Residue] -> Double
aromaticFraction [] = 0
aromaticFraction rs =
  fromIntegral (length (filter (aaIsAromatic . resAa) rs)) / fromIntegral (length rs)

-- | expression = φ^spin · e^{|q|/(π·n)} · (1 + γ·aromatic)
geneExpression :: [Residue] -> Double
geneExpression [] = 1.0
geneExpression rs =
  let spin = meanSpin rs
      n = fromIntegral (length rs)
      q = fromIntegral (abs (chargeBalance rs))
      arom = aromaticFraction rs
      raw = (phi ** spin) * exp (q / (seedPi * n)) * (1.0 + gamma * arom)
   in max 0.05 (min 3.0 raw)

selfTest :: Bool
selfTest =
  let atg = primaryTrip 'A' 'T' 'G'
      -- AG=+1, CT=-1 → A=+1 T=-1 G=+1
      okTrip = atg == (1, -1, 1)
      aaOk = dnaToAa 'A' 'T' 'G' == 'M'
      res = decodeOrf "ATGGCC"
   in okTrip && aaOk && length res == 2 && geneExpression res > 0
