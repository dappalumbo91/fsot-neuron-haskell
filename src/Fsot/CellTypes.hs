-- | Cortical cell classes for genetic FI (Pyr / PV / SST / VIP).
module Fsot.CellTypes
  ( CellType (..)
  , classLabel
  , synapseSign
  , allenRateHz
  ) where

data CellType = Pyr | Pv | Sst | Vip
  deriving (Eq, Ord, Show, Enum, Bounded)

classLabel :: CellType -> String
classLabel Pyr = "Pyr"
classLabel Pv = "PV"
classLabel Sst = "SST"
classLabel Vip = "VIP"

-- | E = +1, I = −1 (pair W sign)
synapseSign :: CellType -> Int
synapseSign Pyr = 1
synapseSign _ = -1

-- | Allen Cre FI rate targets (Hz) — readout anchors (same as Zig scalpel).
allenRateHz :: CellType -> Double
allenRateHz Pyr = 16.35121532610921
allenRateHz Pv = 83.3504049172855
allenRateHz Sst = 29.538052683455557
allenRateHz Vip = 34.81541758294487
