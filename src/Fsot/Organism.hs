-- | Continuous organism: genetic brain + episodic memory (Zig organism_fixed twin).
module Fsot.Organism
  ( Organism (..)
  , initOrganism
  , tick
  , teach
  , ask
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Fsot.Memory (Store, emptyStore, encode, retrieve, rAns, rOk)
import Fsot.Neuron (Neuron, defaultNeuron, step, soFired)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/organism_fixed.zig"

data Organism = Organism
  { oNeurons :: [Neuron]
  , oStore :: Store
  , oTick :: Int
  , oSpikes :: Int
  }
  deriving (Show)

nUnits :: Int
nUnits = 32

initOrganism :: Organism
initOrganism =
  Organism
    { oNeurons = replicate nUnits defaultNeuron
    , oStore = emptyStore
    , oTick = 0
    , oSpikes = 0
    }

-- | Drive population one tick (4 micro-steps).
tick :: Organism -> Double -> Organism
tick o stim =
  let steps = 4
      go 0 ns sp = (ns, sp)
      go k ns sp =
        let stepped = map (\n -> step n stim) ns
            ns' = map fst stepped
            sp' = sp + length (filter soFired (map snd stepped))
         in go (k - 1) ns' sp'
      (ns1, sp1) = go steps (oNeurons o) 0
   in o {oNeurons = ns1, oTick = oTick o + 1, oSpikes = oSpikes o + sp1}

teach :: Organism -> String -> String -> Organism
teach o cue ans = o {oStore = encode (oStore o) cue ans}

ask :: Organism -> String -> (Organism, String, Bool)
ask o cue =
  let h = retrieve (oStore o) cue
   in (o, rAns h, rOk h)

selfTest :: Bool
selfTest =
  let o0 = initOrganism
      o1 = foldl (\o _ -> tick o 0.5) o0 [1 .. 20 :: Int]
      o2 = teach o1 "one and one" "two"
      (_, ans, ok) = ask o2 "one and one"
   in ok && ans == "two" && oSpikes o1 >= 0
