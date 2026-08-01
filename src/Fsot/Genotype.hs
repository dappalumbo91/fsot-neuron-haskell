-- | ORF → expression → phenotype → FI knobs (genetics-as-code).
-- Twin of Zig genotype.zig / genotype_fixed.zig (simplified host path).
module Fsot.Genotype
  ( GeneName (..)
  , GeneProgram (..)
  , Phenotype (..)
  , UnitParams (..)
  , buildGeneProgram
  , phenotypeFromGenes
  , applyClassNudge
  , buildCellTypeGenotype
  , phenotypeFiKnobs
  , mutateOrf
  , classOrf
  , selfTest
  ) where

import Data.Char (toUpper)
import Fsot.CellTypes (CellType (..))
import Fsot.Codon
  ( aromaticFraction
  , chargeBalance
  , decodeOrf
  , geneExpression
  , meanSpin
  )
import Fsot.Seeds (etaEff, neuroDEff, phi, psiCon)

data GeneName = Scn | Kcn | Cacna | Leak
  deriving (Eq, Show, Enum, Bounded)

data GeneProgram = GeneProgram
  { gpName :: GeneName
  , gpSpin :: Double
  , gpExpression :: Double
  , gpCharge :: Int
  , gpAromatic :: Double
  }
  deriving (Show)

data Phenotype = Phenotype
  { phDEff :: Double
  , phFireThr :: Double
  , phRefractory :: Double
  , phAdaptStep :: Double
  , phAdaptGain :: Double
  , phAdaptDecay :: Double
  , phFiStim :: Double
  , phCompositeSpin :: Double
  , phCompositeCharge :: Double
  }
  deriving (Show)

-- | FI unit knobs (Double host twin of Fixed UnitParamsF).
data UnitParams = UnitParams
  { upDEff :: Double
  , upFireThr :: Double
  , upRefSteps :: Int
  , upAdaptGain :: Double
  , upAdaptDecay :: Double
  , upAdaptStep :: Double
  , upFiStim :: Double
  }
  deriving (Show)

-- | Class ORF templates (short synthetic ORFs — same doctrine as Zig cellOrf).
classOrf :: CellType -> GeneName -> String
classOrf Pyr Scn = "ATGGCCACCAAGATCGGCAAG"
classOrf Pyr Kcn = "ATGTTCAAGGTGCCCGACTAC"
classOrf Pyr Cacna = "ATGGAGCTGATCAACGAGTAC"
classOrf Pyr Leak = "ATGAGCCTGCCCAACATCATC"
classOrf Pv Scn = "ATGGCCAAGAAGATCGGCAAG"
classOrf Pv Kcn = "ATGTTCGTGGTGCCCGACTAC"
classOrf Pv Cacna = "ATGGAGCTGGTGAACGAGTAC"
classOrf Pv Leak = "ATGAGCCTGCCCAACGTGATC"
classOrf Sst Scn = "ATGGCCACCAGGATCGGCAAG"
classOrf Sst Kcn = "ATGTTCAAGGTGCCCTACTAC"
classOrf Sst Cacna = "ATGGAGCTGATCAACGACTAC"
classOrf Sst Leak = "ATGAGCCTGCCCAACATCGTG"
classOrf Vip Scn = "ATGGCCACCAAGGTGGGCAAG"
classOrf Vip Kcn = "ATGTTCAAGGTGCCCGACATC"
classOrf Vip Cacna = "ATGGAGCTGATCAACGAGATC"
classOrf Vip Leak = "ATGAGCCTGCCCAACATCAAG"

-- | Trinary-preserving base flips (purine↔purine, pyrimidine↔pyrimidine).
mutateOrf :: String -> Int -> Int -> String
mutateOrf dna unitId locus =
  let n = length dna
      nMut = 1 + (unitId `mod` 4)
      flipBase b = case toUpper b of
        'A' -> 'G'
        'G' -> 'A'
        'C' -> 'T'
        'T' -> 'C'
        'U' -> 'C'
        x -> x
      positions =
        [ fromIntegral ((unitId * 3 + locus * 5 + m * 7) `mod` max 1 n)
        | m <- [0 .. nMut - 1]
        ]
      arr = zip [0 ..] dna
      go (i, b) = if i `elem` positions then flipBase b else b
   in if n == 0 then dna else map go arr

buildGeneProgram :: GeneName -> String -> GeneProgram
buildGeneProgram name dna =
  let res = decodeOrf dna
   in GeneProgram
        { gpName = name
        , gpSpin = meanSpin res
        , gpExpression = geneExpression res
        , gpCharge = chargeBalance res
        , gpAromatic = aromaticFraction res
        }

phenotypeFromGenes :: [GeneProgram] -> Phenotype
phenotypeFromGenes genes =
  let scn = expr Scn
      kcn = expr Kcn
      ca = expr Cacna
      leak = expr Leak
      dEff = clampD 8 20 (neuroDEff + phi * (ca - 1.0) * 0.35 + 0.05 * (leak - 1.0))
      fire = clampD 0.85 1.25 (1.05 - 0.12 * (scn - 1.0) + 0.06 * (kcn - 1.0))
      ref = clampD 4 40 (12.0 * (0.85 + 0.30 * kcn))
      adaptStep = clampD 0 8 (0.7 * (0.6 + 0.8 * ca))
      adaptGain = 0.02 * (0.7 + 0.6 * ca)
      adaptDecay = clampD 0.96 0.995 (0.988 - 0.004 * (ca - 1.0))
      fi = clampD 0.25 0.95 (0.50 * (0.85 + 0.25 * scn - 0.10 * kcn))
      sumSpinW = sum [gpSpin g * gpExpression g | g <- genes]
      sumExpr = sum [gpExpression g | g <- genes]
      sumQ = sum [fromIntegral (gpCharge g) * gpExpression g | g <- genes]
      cspin = if sumExpr == 0 then 0 else sumSpinW / sumExpr
      ccharge = sumQ / 4.0
   in Phenotype dEff fire ref adaptStep adaptGain adaptDecay fi cspin ccharge
  where
    expr n = case [gpExpression g | g <- genes, gpName g == n] of
      (e : _) -> e
      [] -> 1.0
    clampD lo hi x = max lo (min hi x)

applyClassNudge :: CellType -> Phenotype -> Phenotype
applyClassNudge Pv ph =
  ph
    { phRefractory = clampD 3 40 (phRefractory ph * 0.38)
    , phAdaptStep = phAdaptStep ph * 0.28
    , phAdaptGain = phAdaptGain ph * 0.60
    , phFireThr = clampD 0.78 1.25 (phFireThr ph - 0.08)
    , phFiStim = clampD 0.25 1.20 (phFiStim ph * 1.42)
    }
applyClassNudge Sst ph =
  ph
    { phAdaptStep = clampD 0 10 (phAdaptStep ph * 1.4)
    , phRefractory = phRefractory ph * 1.05
    }
applyClassNudge Vip ph =
  ph
    { phFiStim = phFiStim ph * 0.9
    , phDEff = clampD 8 20 (phDEff ph + 0.3 * phi)
    }
applyClassNudge Pyr ph =
  ph
    { phAdaptStep = phAdaptStep ph * 0.95
    , phAdaptGain = phAdaptGain ph * 1.08
    }

clampD :: Double -> Double -> Double -> Double
clampD lo hi x = max lo (min hi x)

buildCellTypeGenotype :: Int -> CellType -> Bool -> (Phenotype, [GeneProgram])
buildCellTypeGenotype unitId ct diversity =
  let names = [Scn, Kcn, Cacna, Leak]
      genes =
        [ let base = classOrf ct name
              dna = if diversity then mutateOrf base unitId (fromEnum name) else base
              g = buildGeneProgram name dna
              -- mild class expression bias placeholder (Zig has expressionBias)
           in g {gpExpression = clampD 0.05 3.5 (gpExpression g)}
        | name <- names
        ]
      ph0 = phenotypeFromGenes genes
      ph = applyClassNudge ct ph0
   in (ph, genes)

-- | Phenotype → FI knobs (Zig phenotypeFiKnobs twin, Double host).
phenotypeFiKnobs :: Phenotype -> UnitParams
phenotypeFiKnobs ph =
  let allenIsi = 70.59855571638475
      allenAd = 0.051153889361673456
      refNet = phRefractory ph
   in if refNet < 9.0
        then -- fast-spiking
          let refI = round (clampD 3 28 (refNet * 1.05)) :: Int
              g = clampD 0.008 0.04 (phAdaptGain ph * 0.85)
              dFs = clampD 0.05 2.5 (phAdaptStep ph * 0.35)
              fi = clampD 0.55 1.15 (phFiStim ph * (0.90 + 0.12 * psiCon) * (0.97 + 0.04 * etaEff))
              thr = clampD 0.78 1.10 (phFireThr ph)
           in UnitParams (phDEff ph) thr refI g (phAdaptDecay ph) dFs fi
        else -- regular-spiking
          let spin = phCompositeSpin ph
              charge = phCompositeCharge ph
              geneScale = clampD 0.55 1.55 (refNet / 13.0)
              rLaw = allenIsi * (1.0 - 0.45 * allenAd)
              refFi0 = rLaw * 0.72 * geneScale * (0.92 + 0.05 * (phi - 1.0))
              refFi1 = refFi0 * (1.0 + 0.40 * spin + 0.12 * charge)
              refFi = clampD 25 140 refFi1
              refI = round refFi :: Int
              a = clampD 0 0.55 allenAd
              d0 = (2.0 * a * max 8.0 refFi) / (9.0 * (1.0 - a) + 1e-9)
              d1 = d0 * 1.85 * clampD 0.5 1.6 (phAdaptStep ph / 0.7)
              d = clampD 0.08 10 (d1 * (1.0 + 0.35 * spin))
              g = clampD 0.022 0.09 (phAdaptGain ph * 1.35 * (1.0 + 0.20 * abs spin))
              fi = clampD 0.30 0.95 (phFiStim ph * (0.88 + 0.20 * psiCon) * (0.95 + 0.08 * etaEff) * (1.0 + 0.18 * spin))
           in UnitParams (phDEff ph) (phFireThr ph) refI g (phAdaptDecay ph) d fi

selfTest :: Bool
selfTest =
  let (ph, _) = buildCellTypeGenotype 0 Pyr False
      kn = phenotypeFiKnobs ph
      (phD, _) = buildCellTypeGenotype 1 Pyr True
      knD = phenotypeFiKnobs phD
   in phCompositeSpin ph > 0.0
        && upRefSteps kn >= 1
        && upRefSteps knD >= 1
