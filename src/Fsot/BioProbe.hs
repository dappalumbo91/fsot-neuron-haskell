-- | Biological FI metrics on a simple integrate-and-fire unit.
-- Host Double twin of Zig bio_probe_fixed (native units: ISI ms, rate Hz, adapt abs).
module Fsot.BioProbe
  ( allenIsiMs
  , allenAdapt
  , minSpikesIsi
  , FiResult (..)
  , runFIUnit
  , paramsFromCellType
  , polishToSpecimen
  , Specimen (..)
  ) where

import Fsot.CellTypes (CellType)
import Fsot.Genotype (UnitParams (..), buildCellTypeGenotype, phenotypeFiKnobs)

allenIsiMs :: Double
allenIsiMs = 70.59855571638475

allenAdapt :: Double
allenAdapt = 0.051153889361673456

minSpikesIsi :: Int
minSpikesIsi = 2

data Specimen = Specimen
  { spIsiMs :: Double
  , spAdapt :: Double
  }
  deriving (Show)

data FiResult = FiResult
  { fiRateHz :: Double
  , fiMeanIsiMs :: Double
  , fiAdapt :: Double
  , fiSpikes :: Int
  }
  deriving (Show)

paramsFromCellType :: CellType -> Int -> Bool -> UnitParams
paramsFromCellType ct unitId diversity =
  let (ph, _) = buildCellTypeGenotype unitId ct diversity
   in phenotypeFiKnobs ph

-- | Discrete FI train: leaky threshold model with refractory + AHP adaptation.
-- Tuned so mean ISI tracks ref_steps on the 1 ms lattice (Zig Fixed doctrine).
runFIUnit :: UnitParams -> Int -> FiResult
runFIUnit p steps =
  let dtMs = 1.0 -- 1 ms lattice (matches Zig Fixed FI step doctrine)
      thr = upFireThr p
      go t s adapt refLeft fires =
        if t >= steps
          then fires
          else
            let (s1, adapt1, ref1, fired) =
                  if refLeft > 0
                    then (0.0, adapt * upAdaptDecay p, refLeft - 1, False)
                    else
                      -- Stronger drive after refractory so ISI ≈ ref_steps under FI stim
                      let drive = max 0.0 (upFiStim p - 0.35 * adapt)
                          leak = 0.88
                          inj = drive * 0.35 * (upDEff p / 13.0)
                          s' = s * leak + inj
                       in if s' >= thr
                            then (0.0, adapt + upAdaptStep p * upAdaptGain p, max 1 (upRefSteps p), True)
                            else (s', adapt * upAdaptDecay p, 0, False)
                fires' = if fired then t : fires else fires
             in go (t + 1) s1 adapt1 ref1 fires'
      spikeTimes = reverse (go 0 0.0 0.0 0 [])
      n = length spikeTimes
      isis =
        if n < 2
          then []
          else zipWith (\a b -> fromIntegral (b - a) * dtMs) spikeTimes (tail spikeTimes)
      meanIsi = if null isis then 0 else sum isis / fromIntegral (length isis)
      rate = if steps <= 0 then 0 else fromIntegral n * 1000.0 / fromIntegral steps
      adaptIdx =
        let m = length isis
         in if m < 6
              then 0
              else
                let third = max 1 (m `div` 3)
                    early = take third isis
                    late = drop (m - third) isis
                    me = sum early / fromIntegral (length early)
                    ml = sum late / fromIntegral (length late)
                 in if me + ml < 1e-9 then 0 else (ml - me) / (ml + me)
   in FiResult rate meanIsi adaptIdx n

specIsiTol :: Double -> Double
specIsiTol isi
  | isi < 35 = max 10.0 (0.28 * isi)
  | otherwise = max 8.0 (0.14 * isi)

-- | Soft polish toward specimen ISI/adapt (Zig polishToSpecimen twin).
-- Seeds refractory from specimen ISI (mapSpecimen-style bridge) then iterates.
polishToSpecimen :: UnitParams -> Specimen -> Int -> UnitParams
polishToSpecimen p0 sp steps = go 0 pSeed
  where
    isiTol = specIsiTol (spIsiMs sp)
    isi = max 8.0 (min 220.0 (spIsiMs sp))
    ad = max (-0.15) (min 0.6 (spAdapt sp))
    fast = isi < 35.0
    stimHi = if fast then 1.40 else 0.95
    refLo = if fast then 3 else 4
    refScale = if fast then 0.52 else 0.72
    ref0 = max refLo (min 160 (round (isi * refScale) :: Int))
    fi0 =
      if fast
        then max 0.55 (min 1.20 (upFiStim p0 * 1.15))
        else max 0.35 (min 0.95 (upFiStim p0))
    g0 =
      if fast
        then max 0.008 (min 0.04 (upAdaptGain p0 * 0.55))
        else max 0.010 (min 0.14 (0.018 + 0.85 * max 0.0 ad))
    d0 =
      let a = max 0.0 (min 0.55 ad)
          r = fromIntegral ref0
          base = if a < 1e-6 then 0.03 else (2.0 * a * r) / (9.0 * (1.0 - a) + 1e-9)
          scaled = base * if fast then 1.15 else (2.05 + 2.2 * max 0.0 (ad - 0.03))
       in max 0.03 (min 14.0 scaled)
    pSeed =
      p0
        { upRefSteps = ref0
        , upFiStim = fi0
        , upAdaptGain = g0
        , upAdaptStep = d0
        , upAdaptDecay = 0.988
        }
    go it p
      | it >= 72 = p
      | otherwise =
          let pr = runFIUnit p steps
           in if fiSpikes pr < 6
                then
                  go
                    (it + 1)
                    p
                      { upRefSteps = max refLo (upRefSteps p - 2)
                      , upFiStim = min stimHi (upFiStim p * 1.08)
                      }
                else
                  let isiErr = abs (fiMeanIsiMs pr - spIsiMs sp)
                      adErr = abs (fiAdapt pr - spAdapt sp)
                   in if isiErr <= isiTol && adErr <= 0.05
                        then p
                        else
                          let p1 =
                                if isiErr > isiTol && fiMeanIsiMs pr > 1
                                  then
                                    if fiMeanIsiMs pr > spIsiMs sp
                                      then
                                        p
                                          { upRefSteps = max refLo (upRefSteps p - 1)
                                          , upFiStim = min stimHi (upFiStim p * (if fast then 1.05 else 1.03))
                                          }
                                      else
                                        p
                                          { upRefSteps = min 180 (upRefSteps p + 1)
                                          , upFiStim = max 0.28 (upFiStim p * 0.97)
                                          }
                                  else p
                              p2 =
                                if adErr > 0.05
                                  then
                                    if fiAdapt pr < spAdapt sp
                                      then
                                        p1
                                          { upAdaptStep = min 12.0 (upAdaptStep p1 * 1.12)
                                          , upAdaptGain = min 0.14 (upAdaptGain p1 * 1.06)
                                          }
                                      else
                                        p1
                                          { upAdaptStep = max 0.04 (upAdaptStep p1 * 0.90)
                                          , upAdaptGain = max 0.012 (upAdaptGain p1 * 0.95)
                                          }
                                  else p1
                           in go (it + 1) p2
