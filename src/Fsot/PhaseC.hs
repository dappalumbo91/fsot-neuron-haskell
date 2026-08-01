-- | Phase C - embodied I/O + stress residual (parallel twin).
module Fsot.PhaseC
  ( runPhaseC
  ) where

import Control.Monad (unless)
import qualified Fsot.BioEmbodied as Emb
import qualified Fsot.ComposeIntel as Compose
import System.Exit (exitFailure)

runPhaseC :: IO ()
runPhaseC = do
  putStrLn "=============================================="
  putStrLn " FSOT PHASE C (Haskell twin - embodied I/O)"
  putStrLn "=============================================="
  putStrLn "order: bio-io -> bio-articulate -> bio-converse -> stress residual"
  putStrLn "parallel stage with Zig + Idris"

  putStrLn ""
  putStrLn "--- C1 BIO-IO ---"
  let io = Emb.runBioIo
  Emb.printBioIo io
  unless (Emb.ioOk io) $ die "FSOT_BIO_IO FAIL"

  putStrLn ""
  putStrLn "--- C2 BIO-ARTICULATE ---"
  let ar = Emb.runArticulate
  Emb.printArticulate ar
  unless (Emb.arOk ar) $ die "FSOT_BIO_ARTICULATE FAIL"

  putStrLn ""
  putStrLn "--- C3 BIO-CONVERSE ---"
  let cv = Emb.runConverse
  Emb.printConverse cv
  unless (Emb.cvOk cv) $ die "FSOT_BIO_CONVERSE FAIL"

  putStrLn ""
  putStrLn "--- C4 STRESS RESIDUAL ---"
  let cr = Compose.runComposeIntel
  Compose.printReport cr
  unless (Compose.crOk cr) $ die "FSOT_COMPOSE FAIL"
  putStrLn "FSOT_STRESS_RESIDUAL PASS"

  putStrLn ""
  putStrLn "=============================================="
  putStrLn " FSOT_PHASE_C PASS"
  putStrLn " FSOT_EMBODIED_IO_OK"
  putStrLn " FSOT_TWIN_PHASE_C_OK"
  putStrLn "=============================================="
  where
    die msg = do
      putStrLn msg
      putStrLn "FSOT_PHASE_C FAIL"
      exitFailure
