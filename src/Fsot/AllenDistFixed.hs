-- | Port of Zig `src/allen_dist_fixed.zig` — FULL CAPABILITY MIRROR.
-- Status: scaffold (wire + implement to match Zig gate).
-- Doctrine: twins are full capable copies of fsot-neuron-zig, not demos.
module Fsot.AllenDistFixed
  ( moduleStatus
  , zigSource
  , selfTest
  ) where

moduleStatus :: String
moduleStatus = "PORT_IN_PROGRESS"

zigSource :: String
zigSource = "src/allen_dist_fixed.zig"

-- | Light compile-time presence test; replace with real gate when ported.
selfTest :: Bool
selfTest = True
