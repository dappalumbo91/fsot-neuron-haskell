-- | Phase A intelligence stack — same order as Zig roadmap.
-- genetic/ephys product + continuous organism + compose + intel-loop + think
module Fsot.PhaseA
  ( runPhaseA
  ) where

import Control.Monad (unless)
import qualified Fsot.AllenIsiKs as Isi
import qualified Fsot.ComposeIntel as Compose
import qualified Fsot.IntelLoop as Loop
import qualified Fsot.InternalThink as Think
import qualified Fsot.Organism as Org
import System.Directory (doesFileExist, getCurrentDirectory)
import System.Exit (exitFailure)
import System.FilePath ((</>))
import Text.Printf (printf)

runPhaseA :: IO ()
runPhaseA = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE A (Haskell twin = Zig Phase A)"
  putStrLn "=============================================="
  putStrLn "order: organism -> compose -> intel-loop -> think-probe -> isi-ks"

  -- 1 continuous organism
  putStrLn ""
  putStrLn "--- A1 ORGANISM ---"
  unless Org.selfTest $ fail "FSOT_ORGANISM FAIL"
  let o0 = Org.initOrganism
      o1 = foldl (\o _ -> Org.tick o 0.5) o0 [1 .. 48 :: Int]
      o2 = Org.teach o1 "one and one" "two"
      (_, ans, ok) = Org.ask o2 "one and one"
  printf "ORGANISM ticks=%d spikes=%d ok=%s ans=%s\n" (Org.oTick o1) (Org.oSpikes o1) (show ok) ans
  unless ok $ fail "FSOT_ORGANISM FAIL"
  putStrLn "FSOT_ORGANISM PASS"

  -- 2 compose
  putStrLn ""
  putStrLn "--- A2 COMPOSE ---"
  let cr = Compose.runComposeIntel
  Compose.printReport cr
  unless (Compose.crOk cr) $ fail "FSOT_COMPOSE FAIL"

  -- 3 intel-loop
  putStrLn ""
  putStrLn "--- A3 INTEL-LOOP ---"
  let lr = Loop.runIntelLoop
  Loop.printReport lr
  unless (Loop.lrOk lr) $ fail "FSOT_INTEL_LOOP FAIL"

  -- 4 think probe (continuous organism internal loop)
  putStrLn ""
  putStrLn "--- A4 THINK PROBE ---"
  tr <- Think.runThinkProbe
  Think.printReport tr
  unless (Think.trOk tr) $ fail "FSOT_THINK FAIL"

  -- 5 Allen ISI KS product
  putStrLn ""
  putStrLn "--- A5 ISI-KS PRODUCT ---"
  unless Isi.selfTest $ fail "FSOT_ISI_KS SELFTEST FAIL"
  cwd <- getCurrentDirectory
  let targets = cwd </> "data" </> "allen" </> "allen_dist_targets.txt"
      s256 = cwd </> "data" </> "allen" </> "allen_sample_256.txt"
      s128 = cwd </> "data" </> "allen" </> "allen_sample_128.txt"
  ex <- doesFileExist targets
  unless ex $ fail ("missing " ++ targets)
  r <- Isi.runIsiKsProduct targets s256 s128
  Isi.printReport r
  unless (Isi.prOk r) $ fail "FSOT_ISI_KS FAIL"

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_A PASS"
  putStrLn " FSOT_CONTINUOUS_ORGANISM_OK"
  putStrLn " FSOT_TWIN_PHASE_A_OK"
  putStrLn "=============================================="
  where
    fail msg = do
      putStrLn msg
      putStrLn "FSOT_PHASE_A FAIL"
      exitFailure
