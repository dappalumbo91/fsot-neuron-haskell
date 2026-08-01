-- | FSOT seed constants (φ, π, γ, η, ψ …) — shared with Zig seeds_fixed.
-- Values match archive pin path; not free-fit per experiment.
module Fsot.Seeds
  ( phi
  , seedPi
  , gamma
  , etaEff
  , psiCon
  , neuroNChannels
  , neuroP
  , neuroDEff
  , restingS
  ) where

phi :: Double
phi = 1.618033988749895

-- | π (named seedPi so it does not clash with Prelude.pi)
seedPi :: Double
seedPi = 3.141592653589793

gamma :: Double
gamma = 0.5772156649015329

etaEff :: Double
etaEff = 0.85

psiCon :: Double
psiCon = 0.72

neuroNChannels :: Double
neuroNChannels = 8.0

neuroP :: Double
neuroP = 0.35

neuroDEff :: Double
neuroDEff = 13.0

restingS :: Double
restingS = 0.45
