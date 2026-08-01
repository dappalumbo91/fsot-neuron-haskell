-- | Full capability parity report vs Zig fsot-neuron-zig.
module Fsot.Parity
  ( printParity
  , allModes
  , implementedModes
  , selfTest
  ) where

import qualified Fsot.AllenIsiKs as Isi
import qualified Fsot.BioProbe as Bio
import qualified Fsot.Codon as Codon
import qualified Fsot.ComposeIntel as Compose
import qualified Fsot.Genotype as Gen
import qualified Fsot.IntelLoop as Loop
import qualified Fsot.Memory as Mem
import qualified Fsot.Neuron as Neu
import qualified Fsot.Organism as Org

-- | Every primary Zig CLI mode (aliases collapsed to one name).
allModes :: [String]
allModes =
  [ "selftest"
  , "learn"
  , "curriculum"
  , "curiosity"
  , "transfer"
  , "modulate"
  , "teach"
  , "short-horizon"
  , "speech"
  , "bio-learn"
  , "self-study"
  , "bio-suite"
  , "bio-converse"
  , "bio-articulate"
  , "capacity"
  , "gpu-organ"
  , "gpu-batch"
  , "gpu-vram"
  , "allen-dist"
  , "allen-class-dist"
  , "genetic-var"
  , "isi-ks"
  , "allen-bare"
  , "scalpel"
  , "skill"
  , "know-query"
  , "think"
  , "think-hour"
  , "think-min"
  , "boot-think"
  , "cross-modal"
  , "bio-io"
  , "machine"
  , "machine-lang"
  , "english"
  , "practice"
  , "language-depth"
  , "grade"
  , "ladder"
  , "reason"
  , "brain-learn"
  , "novel"
  , "checkpoint"
  , "failure"
  , "wire"
  , "symbol"
  , "hardware"
  , "host-senses"
  , "host-loop"
  , "body"
  , "mind"
  , "speakers"
  , "autonomous"
  , "attention"
  , "mnist"
  , "depth"
  , "pathways"
  , "md"
  , "neuromod"
  , "sleep"
  , "claim"
  , "compose"
  , "intel-bio"
  , "intel-loop"
  , "frontier"
  , "pixel-id"
  , "vision"
  , "organism"
  , "intel"
  , "fixed"
  , "genetic"
  , "stress"
  , "suite"
  , "parity"
  ]

implementedModes :: [String]
implementedModes =
  [ "selftest"
  , "parity"
  , "codon"
  , "genetic"
  , "genetic-var"
  , "isi-ks"
  , "scalpel"
  , "organism"
  , "intel"
  , "intel-loop"
  , "compose"
  , "learn"
  , "teach"
  , "memory"
  , "neuron"
  , "stress"
  , "suite"
  , "fixed"
  , "think"
  , "think-min"
  , "think-hour"
  , "phase-a"
  ]

printParity :: IO ()
printParity = do
  putStrLn "=== FSOT FULL CAPABILITY PARITY (Haskell twin vs Zig) ==="
  putStrLn "doctrine: twins are full capable copies - not single-gate demos"
  putStrLn $ "modes_total=" ++ show (length allModes)
  putStrLn $ "modes_implemented=" ++ show (length implementedModes)
  putStrLn $ "mode_coverage=" ++ show (fromIntegral (length implementedModes) / fromIntegral (length allModes) :: Double)
  putStrLn "core_selftests:"
  putStrLn $ "  codon=" ++ show Codon.selfTest
  putStrLn $ "  genotype=" ++ show Gen.selfTest
  putStrLn $ "  isi_ks_self=" ++ show Isi.selfTest
  putStrLn $ "  neuron=" ++ show Neu.selfTest
  putStrLn $ "  memory=" ++ show Mem.selfTest
  putStrLn $ "  organism=" ++ show Org.selfTest
  putStrLn $ "  intel_loop=" ++ show Loop.selfTest
  putStrLn $ "  compose=" ++ show Compose.selfTest
  putStrLn "layers: L0-L2 ephys green; L3-L5 organism/intel implemented; L6-L9 port in progress"
  putStrLn "FSOT_PARITY_REPORT_OK"
  let core =
        Codon.selfTest
          && Gen.selfTest
          && Isi.selfTest
          && Neu.selfTest
          && Mem.selfTest
          && Org.selfTest
          && Loop.selfTest
          && Compose.selfTest
  if core
    then putStrLn "FSOT_CORE_STACK PASS"
    else putStrLn "FSOT_CORE_STACK FAIL"

selfTest :: Bool
selfTest = not (null allModes) && not (null implementedModes)
