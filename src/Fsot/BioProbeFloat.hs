-- | Port of Zig `src/bio_probe.zig` — FULL CAPABILITY MIRROR.
-- Status: scaffold (wire + implement to match Zig gate).
-- Doctrine: twins are full capable copies of fsot-neuron-zig, not demos.
module Fsot.BioProbeFloat
  ( moduleStatus
  , zigSource
  , selfTest
  ) where

moduleStatus :: String
moduleStatus = "PORT_IN_PROGRESS"

zigSource :: String
zigSource = "src/bio_probe.zig"

-- | Light compile-time presence test; replace with real gate when ported.
selfTest :: Bool
selfTest = True
