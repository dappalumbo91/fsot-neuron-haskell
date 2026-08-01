-- | Fixed-lattice neuron (host Double twin of Zig neuron_fixed.zig).
-- Full capability: step dynamics, refractory, adapt AHP, FI-ready.
module Fsot.Neuron
  ( Neuron (..)
  , defaultNeuron
  , reset
  , step
  , StepOut (..)
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Fsot.Seeds (etaEff, neuroDEff, psiCon)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/neuron_fixed.zig"

data Neuron = Neuron
  { nS :: Double
  , nPhase :: Double
  , nRefractory :: Int
  , nAdapt :: Double
  , nSpikeCount :: Int
  , nDEff :: Double
  , nFireThr :: Double
  , nRefSteps :: Int
  , nAdaptStep :: Double
  , nAdaptGain :: Double
  , nAdaptDecay :: Double
  , nRestingS :: Double
  }
  deriving (Show)

data StepOut = StepOut
  { soS :: Double
  , soFired :: Bool
  , soPhase :: Double
  }
  deriving (Show)

defaultNeuron :: Neuron
defaultNeuron =
  Neuron
    { nS = 0.45
    , nPhase = 0.05
    , nRefractory = 0
    , nAdapt = 0
    , nSpikeCount = 0
    , nDEff = neuroDEff
    , nFireThr = 1.05
    , nRefSteps = 12
    , nAdaptStep = 0.7
    , nAdaptGain = 0.02
    , nAdaptDecay = 0.988
    , nRestingS = 0.45
    }

reset :: Neuron -> Neuron
reset n = n {nS = nRestingS n, nPhase = 0.05, nRefractory = 0, nAdapt = 0, nSpikeCount = 0}

-- | One lattice step (1 ms doctrine).
step :: Neuron -> Double -> (Neuron, StepOut)
step n stim =
  let inRef = nRefractory n > 0
      adapt' = nAdapt n * nAdaptDecay n
      stimEff = max (-0.5) (min 1.5 (stim - adapt'))
      drive = stimEff * 0.22 * (nDEff n / 13.0) * (0.9 + 0.1 * psiCon) * (0.95 + 0.05 * etaEff)
      sCand =
        if inRef
          then nRestingS n * 0.5
          else nS n * 0.90 + drive + nRestingS n * 0.02
      thr = nFireThr n
      fired = not inRef && sCand >= thr
      (s1, ref1, adapt1, spikes1) =
        if fired
          then (nRestingS n, nRefSteps n, adapt' + nAdaptStep n * nAdaptGain n, nSpikeCount n + 1)
          else
            ( sCand
            , if inRef then nRefractory n - 1 else 0
            , adapt'
            , nSpikeCount n
            )
      phase1 = nPhase n + 0.08 + if fired then 0.5 else 0
      n' =
        n
          { nS = s1
          , nPhase = phase1
          , nRefractory = max 0 ref1
          , nAdapt = adapt1
          , nSpikeCount = spikes1
          }
   in (n', StepOut s1 fired phase1)

selfTest :: Bool
selfTest =
  let n0 = defaultNeuron
      go 0 n sp = sp
      go k n sp =
        let (n', o) = step n 0.55
         in go (k - 1) n' (sp + if soFired o then 1 else 0)
      spikes = go (200 :: Int) n0 0
   in spikes >= 1
