-- | Port of Zig `src/sleep_replay_fixed.zig` — FULL CAPABILITY MIRROR.
-- Status: scaffold (wire + implement to match Zig gate).
-- Doctrine: twins are full capable copies of fsot-neuron-zig, not demos.
module Fsot.SleepReplayFixed
  ( moduleStatus
  , zigSource
  , selfTest
  ) where

moduleStatus :: String
moduleStatus = "PORT_IN_PROGRESS"

zigSource :: String
zigSource = "src/sleep_replay_fixed.zig"

-- | Light compile-time presence test; replace with real gate when ported.
selfTest :: Bool
selfTest = True
