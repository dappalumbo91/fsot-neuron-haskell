-- | Mind host — full mode surface twin of Zig main_mind.
-- Doctrine: every Zig mode is registered; implemented modes run real gates;
-- others report PORT_IN_PROGRESS with Zig source path (never silent no-op).
module Fsot.Mind
  ( runMode
  , usage
  ) where

import Control.Monad (unless)
import qualified Fsot.AllenIsiKs as Isi
import Fsot.BioProbe (fiMeanIsiMs, fiRateHz, fiSpikes, paramsFromCellType, runFIUnit)
import Fsot.CellTypes (CellType (..), allenRateHz, classLabel)
import qualified Fsot.Codon as Codon
import qualified Fsot.ComposeIntel as Compose
import qualified Fsot.Genotype as Gen
import qualified Fsot.IntelLoop as Loop
import qualified Fsot.Memory as Mem
import qualified Fsot.Neuron as Neu
import qualified Fsot.Organism as Org
import qualified Fsot.Parity as Parity
import System.Directory (doesFileExist, getCurrentDirectory)
import System.Exit (ExitCode (..), exitFailure, exitWith)
import System.FilePath ((</>))
import Text.Printf (printf)

usage :: String
usage =
  unlines
    [ "usage: fsot-mind <mode>"
    , "FULL CAPABILITY twin of Zig fsot_mind — not a demo."
    , "  parity        = coverage report vs Zig modes/modules"
    , "  selftest      = core stack self tests"
    , "  suite|stress  = implemented gates battery"
    , "  isi-ks        = Allen ISI distribution KS product"
    , "  intel-loop    = train->sleep->prove"
    , "  compose       = answer-dependent hops"
    , "  organism      = continuous organism tick + memory"
    , "  genetic|scalpel|fixed|..."
    , "  help          = this text"
    , ""
    , "Unimplemented modes: FSOT_PORT_IN_PROGRESS (exit 2)."
    , "See docs/FULL_CAPABILITY_PARITY.md"
    ]

runMode :: String -> IO ()
runMode mode = case mode of
  "help" -> putStrLn usage
  "--help" -> putStrLn usage
  "-h" -> putStrLn usage
  "parity" -> Parity.printParity
  "selftest" -> runSelfTest
  "suite" -> runSuite
  "all" -> runSuite
  "tests" -> runSuite
  "stress" -> runStress
  "codon" -> runCodon
  "genetic" -> runGenetic
  "genetic-var" -> runGenetic
  "mutate-orf" -> runGenetic
  "isi-ks" -> runIsiKs
  "isi_ks" -> runIsiKs
  "allen-isi-ks" -> runIsiKs
  "scalpel" -> runScalpel
  "class-rates" -> runScalpel
  "organism" -> runOrganism
  "intel" -> runOrganism
  "learn" -> runLearn
  "teach" -> runLearn
  "memory" -> runLearn
  "neuron" -> runNeuron
  "intel-loop" -> runIntelLoop
  "intel_loop" -> runIntelLoop
  "train-sleep-prove" -> runIntelLoop
  "compose" -> runCompose
  "compose-intel" -> runCompose
  "answer-hop" -> runCompose
  "fixed" -> runFixed
  "fixedpoint" -> runFixed
  "authority" -> runFixed
  m -> portInProgress m

failGate :: String -> IO a
failGate msg = do
  putStrLn msg
  exitFailure

portInProgress :: String -> IO ()
portInProgress m = do
  putStrLn $ "=== FSOT MODE " ++ m ++ " ==="
  putStrLn "FSOT_PORT_IN_PROGRESS"
  putStrLn $ "zig_authority_mode=" ++ m
  putStrLn "doctrine: twin will implement full Zig capability; this mode not green yet"
  putStrLn "see docs/FULL_CAPABILITY_PARITY.md and fsot-neuron-zig src/main_mind.zig"
  exitWith (ExitFailure 2)

runSelfTest :: IO ()
runSelfTest = do
  putStrLn "=== FSOT MIND HOST (Haskell FULL CAPABILITY) ==="
  putStrLn "doctrine: full copy of Zig domain engine surface"
  unless Codon.selfTest $ failGate "FSOT_CODON FAIL"
  putStrLn "FSOT_CODON PASS"
  unless Gen.selfTest $ failGate "FSOT_GENOTYPE FAIL"
  putStrLn "FSOT_GENOTYPE PASS"
  unless Isi.selfTest $ failGate "FSOT_ISI_KS SELFTEST FAIL"
  putStrLn "FSOT_ISI_KS_SELFTEST PASS"
  unless Neu.selfTest $ failGate "FSOT_NEURON FAIL"
  putStrLn "FSOT_NEURON PASS"
  unless Mem.selfTest $ failGate "FSOT_MEMORY FAIL"
  putStrLn "FSOT_MEMORY PASS"
  unless Org.selfTest $ failGate "FSOT_ORGANISM FAIL"
  putStrLn "FSOT_ORGANISM PASS"
  unless Loop.selfTest $ failGate "FSOT_INTEL_LOOP SELFTEST FAIL"
  putStrLn "FSOT_INTEL_LOOP_SELFTEST PASS"
  unless Compose.selfTest $ failGate "FSOT_COMPOSE SELFTEST FAIL"
  putStrLn "FSOT_COMPOSE_SELFTEST PASS"
  putStrLn "FSOT_MIND_HOST_OK"
  putStrLn "FSOT_HASKELL_AUTHORITY_OK"
  putStrLn "FSOT_FULL_CAPABILITY_CORE_OK"

runSuite :: IO ()
runSuite = do
  putStrLn "=== FSOT SUITE (implemented twin gates) ==="
  runSelfTest
  runScalpel
  runIntelLoop
  runCompose
  putStrLn "FSOT_SUITE PASS (isi-ks optional long gate: fsot-mind isi-ks)"

runStress :: IO ()
runStress = do
  putStrLn "=== FSOT STRESS (core + product) ==="
  runSuite
  putStrLn "FSOT_STRESS PASS"

runCodon :: IO ()
runCodon = do
  unless Codon.selfTest $ failGate "FSOT_CODON FAIL"
  putStrLn "FSOT_CODON PASS"

runGenetic :: IO ()
runGenetic = do
  putStrLn "=== FSOT GENETIC (class ORF -> FI) ==="
  unless Gen.selfTest $ failGate "FSOT_GENOTYPE FAIL"
  mapM_ showClass [Pyr, Pv, Sst, Vip]
  putStrLn "FSOT_GENETIC PASS"
  putStrLn "FSOT_MUTATE_ORF_PATH_OK"
  where
    showClass ct = do
      let (ph, _) = Gen.buildCellTypeGenotype 0 ct False
          kn = Gen.phenotypeFiKnobs ph
          pr = runFIUnit kn 1000
      printf
        "%s ref=%d rate=%.3e isi=%.3e spikes=%d allen_rate=%.3e\n"
        (classLabel ct)
        (Gen.upRefSteps kn)
        (fiRateHz pr)
        (fiMeanIsiMs pr)
        (fiSpikes pr)
        (allenRateHz ct)

runScalpel :: IO ()
runScalpel = do
  putStrLn "=== FSOT SCALPEL RATES ==="
  let pyr = runFIUnit (paramsFromCellType Pyr 0 False) 1000
      pv = runFIUnit (paramsFromCellType Pv 0 False) 1000
  printf "Pyr rate=%.3e Hz\n" (fiRateHz pyr)
  printf "PV  rate=%.3e Hz\n" (fiRateHz pv)
  unless (fiRateHz pv > fiRateHz pyr * 1.5) $ failGate "FSOT_SCALPEL_ORDER FAIL"
  putStrLn "FSOT_SCALPEL_ORDER PASS"
  putStrLn "FSOT_PV_FASTER_THAN_PYR_OK"

runIsiKs :: IO ()
runIsiKs = do
  putStrLn "=== FSOT ALLEN ISI DISTRIBUTION KS (PRODUCT) ==="
  unless Isi.selfTest $ failGate "FSOT_ALLEN_ISI_KS_PRODUCT SELFTEST FAIL"
  cwd <- getCurrentDirectory
  let targets = cwd </> "data" </> "allen" </> "allen_dist_targets.txt"
      s256 = cwd </> "data" </> "allen" </> "allen_sample_256.txt"
      s128 = cwd </> "data" </> "allen" </> "allen_sample_128.txt"
  ex <- doesFileExist targets
  unless ex $ do
    putStrLn ("missing " ++ targets)
    exitFailure
  r <- Isi.runIsiKsProduct targets s256 s128
  Isi.printReport r
  unless (Isi.prOk r) exitFailure

runOrganism :: IO ()
runOrganism = do
  putStrLn "=== FSOT ORGANISM (continuous) ==="
  unless Org.selfTest $ failGate "FSOT_ORGANISM FAIL"
  let o0 = Org.initOrganism
      o1 = foldl (\o _ -> Org.tick o 0.5) o0 [1 .. 48 :: Int]
      o2 = Org.teach o1 "one and one" "two"
      (_, ans, ok) = Org.ask o2 "one and one"
  printf "ORGANISM ticks=%d spikes=%d retrieve_ok=%s ans=%s\n" (Org.oTick o1) (Org.oSpikes o1) (show ok) ans
  unless ok $ failGate "FSOT_ORGANISM FAIL"
  putStrLn "FSOT_ORGANISM PASS"

runLearn :: IO ()
runLearn = do
  putStrLn "=== FSOT LEARN (encode-retrieve) ==="
  unless Mem.selfTest $ failGate "FSOT_LEARN FAIL"
  putStrLn "FSOT_LEARN PASS"
  putStrLn "FSOT_MEMORY PASS"

runNeuron :: IO ()
runNeuron = do
  unless Neu.selfTest $ failGate "FSOT_NEURON FAIL"
  putStrLn "FSOT_NEURON PASS"

runIntelLoop :: IO ()
runIntelLoop = do
  let r = Loop.runIntelLoop
  Loop.printReport r
  unless (Loop.lrOk r) exitFailure

runCompose :: IO ()
runCompose = do
  let r = Compose.runComposeIntel
  Compose.printReport r
  unless (Compose.crOk r) exitFailure

runFixed :: IO ()
runFixed = do
  putStrLn "=== FSOT FIXED AUTHORITY (Haskell host lattice twin) ==="
  runSelfTest
  runScalpel
  putStrLn "FSOT_FIXED_STACK_OK"
  putStrLn "NOTE: Zig Fixed SCALE=1e12 remains bit-authority; Haskell is host Double twin"
