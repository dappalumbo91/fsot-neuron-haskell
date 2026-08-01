-- | Port of Zig `src/stdp_fixed.zig` — FULL CAPABILITY MIRROR.
-- Status: scaffold (wire + implement to match Zig gate).
-- Doctrine: twins are full capable copies of fsot-neuron-zig, not demos.
module Fsot.StdpFixed
  ( moduleStatus
  , zigSource
  , selfTest
  ) where

moduleStatus :: String
moduleStatus = "PORT_IN_PROGRESS"

zigSource :: String
zigSource = "src/stdp_fixed.zig"

-- | Light compile-time presence test; replace with real gate when ported.
selfTest :: Bool
selfTest = True
