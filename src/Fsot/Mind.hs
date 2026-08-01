-- | Mind host modes (Haskell twin of Zig main_mind subset).
module Fsot.Mind
  ( runMode
  , usage
  ) where

import Control.Monad (unless)
import qualified Fsot.AllenIsiKs as Isi
import Fsot.BioProbe (fiMeanIsiMs, fiRateHz, fiSpikes, paramsFromCellType, runFIUnit)
import Fsot.CellTypes (CellType (..), allenRateHz, classLabel)
import qualified Fsot.Codon as Codon
import qualified Fsot.Genotype as Gen
import System.Directory (doesFileExist, getCurrentDirectory)
import System.Exit (exitFailure)
import System.FilePath ((</>))
import Text.Printf (printf)

usage :: String
usage =
  unlines
    [ "usage: fsot-mind <mode>"
    , "  selftest   = codon + genotype + isi-ks self tests"
    , "  codon      = 64-codon primary map gate"
    , "  genetic    = class ORF -> phenotype -> FI knobs smoke"
    , "  isi-ks     = full ISI distribution KS product (Allen CSV)"
    , "  scalpel    = class rate smoke (Pyr/PV/SST/VIP order)"
    , "  help       = this text"
    , ""
    , "Twin of Zig fsot_mind (I:\\fsot-neuron-zig). Run from project root so data/ resolves."
    ]

runMode :: String -> IO ()
runMode mode = case mode of
  "help" -> putStrLn usage
  "--help" -> putStrLn usage
  "-h" -> putStrLn usage
  "selftest" -> runSelfTest
  "codon" -> runCodon
  "genetic" -> runGenetic
  "genetic-var" -> runGenetic
  "isi-ks" -> runIsiKs
  "isi_ks" -> runIsiKs
  "allen-isi-ks" -> runIsiKs
  "scalpel" -> runScalpel
  "class-rates" -> runScalpel
  _ -> do
    putStrLn ("unknown mode: " ++ mode)
    putStrLn usage
    exitFailure

failGate :: String -> IO a
failGate msg = do
  putStrLn msg
  exitFailure

runSelfTest :: IO ()
runSelfTest = do
  putStrLn "=== FSOT MIND HOST (Haskell) ==="
  putStrLn "doctrine: fixed lattice + 64-codon genetics; Allen readout; twin of Zig"
  unless Codon.selfTest $ failGate "FSOT_CODON FAIL"
  putStrLn "FSOT_CODON PASS 64_primary AG=+1 CT=-1 ATG=[+1,-1,+1]"
  unless Gen.selfTest $ failGate "FSOT_GENOTYPE FAIL"
  putStrLn "FSOT_GENOTYPE PASS codon_spine"
  unless Isi.selfTest $ failGate "FSOT_ISI_KS SELFTEST FAIL"
  putStrLn "FSOT_ISI_KS_SELFTEST PASS"
  putStrLn "FSOT_MIND_HOST_OK"
  putStrLn "FSOT_HASKELL_AUTHORITY_OK"

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
  putStrLn "=== FSOT SCALPEL RATES (smoke - Haskell) ==="
  putStrLn "doctrine: PV >> Pyr class order from genetic FI (full abs-Hz iron is Zig primary)"
  let pyr = runFIUnit (paramsFromCellType Pyr 0 False) 1000
      pv = runFIUnit (paramsFromCellType Pv 0 False) 1000
      sst = runFIUnit (paramsFromCellType Sst 0 False) 1000
      vip = runFIUnit (paramsFromCellType Vip 0 False) 1000
  printf "Pyr rate=%.3e Hz\n" (fiRateHz pyr)
  printf "PV  rate=%.3e Hz\n" (fiRateHz pv)
  printf "SST rate=%.3e Hz\n" (fiRateHz sst)
  printf "VIP rate=%.3e Hz\n" (fiRateHz vip)
  let orderOk = fiRateHz pv > fiRateHz pyr * 1.5
  if orderOk
    then do
      putStrLn "FSOT_SCALPEL_ORDER PASS"
      putStrLn "FSOT_PV_FASTER_THAN_PYR_OK"
    else do
      putStrLn "FSOT_SCALPEL_ORDER FAIL"
      exitFailure

runIsiKs :: IO ()
runIsiKs = do
  putStrLn "=== FSOT ALLEN ISI DISTRIBUTION KS (PRODUCT - HASKELL) ==="
  unless Isi.selfTest $ failGate "FSOT_ALLEN_ISI_KS_PRODUCT SELFTEST FAIL"
  cwd <- getCurrentDirectory
  let targets = cwd </> "data" </> "allen" </> "allen_dist_targets.txt"
      s256 = cwd </> "data" </> "allen" </> "allen_sample_256.txt"
      s128 = cwd </> "data" </> "allen" </> "allen_sample_128.txt"
  ex <- doesFileExist targets
  unless ex $ do
    putStrLn ("missing " ++ targets)
    putStrLn "Run from the project root (Desktop\\FSOT NEURON haskell)."
    exitFailure
  r <- Isi.runIsiKsProduct targets s256 s128
  Isi.printReport r
  unless (Isi.prOk r) exitFailure
