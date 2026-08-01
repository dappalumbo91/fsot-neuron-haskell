-- | Phase B stack - experience intelligence + stress residual (parallel twin).
module Fsot.PhaseB
  ( runPhaseB
  ) where

import Control.Monad (unless)
import qualified Fsot.BioLearn as Bio
import qualified Fsot.ComposeIntel as Compose
import qualified Fsot.Organism as Org
import System.Exit (exitFailure)

runPhaseB :: IO ()
runPhaseB = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE B (Haskell twin - experience intelligence)"
  putStrLn "=============================================="
  putStrLn "order: bio-learn -> stress residual (organism+compose)"
  putStrLn "parallel stage with Zig + Idris"

  putStrLn ""
  putStrLn "--- B1 BIO-LEARN (experience intelligence) ---"
  let br = Bio.runBioLearn
  Bio.printReport br
  unless (Bio.blOk br) $ fail "FSOT_BIO_LEARN FAIL"

  putStrLn ""
  putStrLn "--- B2 STRESS RESIDUAL (Phase A product floor) ---"
  unless Org.selfTest $ fail "FSOT_ORGANISM FAIL"
  let o0 = Org.initOrganism
      o1 = foldl (\o _ -> Org.tick o 0.5) o0 [1 .. 24 :: Int]
      o2 = Org.teach o1 "one and one" "two"
      (_, _, ok) = Org.ask o2 "one and one"
  unless ok $ fail "FSOT_ORGANISM FAIL"
  putStrLn "FSOT_ORGANISM PASS"
  let cr = Compose.runComposeIntel
  Compose.printReport cr
  unless (Compose.crOk cr) $ fail "FSOT_COMPOSE FAIL"
  putStrLn "FSOT_STRESS_RESIDUAL PASS"

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_B PASS"
  putStrLn " FSOT_EXPERIENCE_INTELLIGENCE_OK"
  putStrLn " FSOT_TWIN_PHASE_B_OK"
  putStrLn "=============================================="
  where
    fail msg = do
      putStrLn msg
      putStrLn "FSOT_PHASE_B FAIL"
      exitFailure
