-- | Mind host - full mode surface twin of Zig main_mind.
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
import qualified Fsot.InternalThink as Think
import qualified Fsot.Memory as Mem
import qualified Fsot.Neuron as Neu
import qualified Fsot.Organism as Org
import qualified Fsot.Parity as Parity
import qualified Fsot.BioLearn as Bio
import qualified Fsot.BioEmbodied as Emb
import qualified Fsot.PhaseA as PhaseA
import qualified Fsot.PhaseB as PhaseB
import qualified Fsot.PhaseC as PhaseC
import qualified Fsot.PhaseD as PhaseD
import qualified Fsot.GliaFixed as Glia
import qualified Fsot.SelfTalk as SelfTalk
import qualified Fsot.LiveMind as Live
import System.Directory (doesFileExist, getCurrentDirectory)
import System.Environment (getArgs)
import System.Exit (ExitCode (..), exitFailure, exitWith)
import System.FilePath ((</>))
import Text.Printf (printf)
import Text.Read (readMaybe)

usage :: String
usage =
  unlines
    [ "usage: fsot-mind <mode> [args]"
    , "FULL CAPABILITY twin of Zig fsot_mind - Phase A included."
    , "  phase-a       = organism + compose + intel-loop + think + isi-ks"
    , "  phase-b       = bio-learn experience intelligence + stress residual"
    , "  phase-c       = embodied I/O (bio-io + articulate + converse)"
    , "  phase-d       = scientific packaging (Lean stamp + matrix)"
    , "  bio-learn     = animal/human learning suite (NOT LLM)"
    , "  think         = continuous organism think probe"
    , "  think-min N   = think for N wall-clock minutes"
    , "  think-hour    = think for 60 minutes"
    , "  organism|intel-loop|compose|isi-ks|suite|stress|genetic|..."
    , "  parity|selftest|fixed|help"
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
  "phase-a" -> PhaseA.runPhaseA
  "phase_a" -> PhaseA.runPhaseA
  "phasea" -> PhaseA.runPhaseA
  "phase-b" -> PhaseB.runPhaseB
  "phase_b" -> PhaseB.runPhaseB
  "phaseb" -> PhaseB.runPhaseB
  "experience-intelligence" -> PhaseB.runPhaseB
  "phase-c" -> PhaseC.runPhaseC
  "phase_c" -> PhaseC.runPhaseC
  "phasec" -> PhaseC.runPhaseC
  "embodied" -> PhaseC.runPhaseC
  "embodied-io" -> PhaseC.runPhaseC
  "phase-d" -> PhaseD.runPhaseD
  "phase_d" -> PhaseD.runPhaseD
  "phased" -> PhaseD.runPhaseD
  "scientific" -> PhaseD.runPhaseD
  "scientific-packaging" -> PhaseD.runPhaseD
  "bio-learn" -> do
    let r = Bio.runBioLearn
    Bio.printReport r
    unless (Bio.blOk r) exitFailure
  "bio_learn" -> runMode "bio-learn"
  "animal-learn" -> runMode "bio-learn"
  "bio-io" -> do
    let r = Emb.runBioIo
    Emb.printBioIo r
    unless (Emb.ioOk r) exitFailure
  "bio-articulate" -> do
    let r = Emb.runArticulate
    Emb.printArticulate r
    unless (Emb.arOk r) exitFailure
  "bio-converse" -> do
    let r = Emb.runConverse
    Emb.printConverse r
    unless (Emb.cvOk r) exitFailure
  "glia-ca" -> do
    let r = Glia.runGliaProduct 120
    Glia.printGliaProduct r
    unless (Glia.gpOk r) exitFailure
  "glia-product" -> runMode "glia-ca"
  "astrocyte" -> runMode "glia-ca"
  "self-talk" -> do
    let r = SelfTalk.runSelfTalk
    SelfTalk.printReport r
    unless (SelfTalk.stOk r) exitFailure
  "self_talk" -> runMode "self-talk"
  "internal-speech" -> runMode "self-talk"
  "mind" -> Live.runLiveMind
  "live" -> Live.runLiveMind
  "live-mind" -> Live.runLiveMind
  "live_mind" -> Live.runLiveMind
  "connected" -> Live.runLiveMind
  "awake" -> Live.runLiveMind
  "mind-auto" -> Live.runLiveMindAuto 120
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
  "think" -> runThink
  "internal-think" -> runThink
  "think-hour" -> runThinkHour
  "think_hour" -> runThinkHour
  "hour-think" -> runThinkHour
  "think-min" -> runThinkMin
  "think_min" -> runThinkMin
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
  unless Think.selfTest $ failGate "FSOT_THINK SELFTEST FAIL"
  putStrLn "FSOT_THINK_SELFTEST PASS"
  putStrLn "FSOT_MIND_HOST_OK"
  putStrLn "FSOT_HASKELL_AUTHORITY_OK"
  putStrLn "FSOT_FULL_CAPABILITY_CORE_OK"

runSuite :: IO ()
runSuite = do
  putStrLn "=== FSOT SUITE (Phase A twin gates) ==="
  runSelfTest
  runScalpel
  runOrganism
  runIntelLoop
  runCompose
  runThink
  putStrLn "FSOT_SUITE PASS (full phase-a + isi-ks: fsot-mind phase-a)"

runStress :: IO ()
runStress = do
  putStrLn "=== FSOT STRESS (Phase A product) ==="
  PhaseA.runPhaseA
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

runThink :: IO ()
runThink = do
  r <- Think.runThinkProbe
  Think.printReport r
  unless (Think.trOk r) exitFailure

runThinkHour :: IO ()
runThinkHour = do
  putStrLn "=== FSOT THINK-HOUR (60 wall-clock minutes) ==="
  r <- Think.runThinkMinutes 60
  Think.printReport r
  unless (Think.trOk r) exitFailure

runThinkMin :: IO ()
runThinkMin = do
  args <- getArgs
  let mins = case args of
        (_ : _ : n : _) -> maybe 1 id (readMaybe n)
        _ -> 1
  putStrLn $ "=== FSOT THINK-MIN " ++ show mins ++ " ==="
  r <- Think.runThinkMinutes mins
  Think.printReport r
  unless (Think.trOk r) exitFailure
