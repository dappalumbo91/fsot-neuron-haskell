module Main where

import qualified Fsot.AllenIsiKs as Isi
import qualified Fsot.Codon as Codon
import qualified Fsot.Genotype as Gen
import System.Exit (exitFailure, exitSuccess)

main :: IO ()
main = do
  let ok =
        Codon.selfTest
          && Gen.selfTest
          && Isi.selfTest
  if ok
    then do
      putStrLn "FSOT_HASKELL_TEST PASS"
      exitSuccess
    else do
      putStrLn "FSOT_HASKELL_TEST FAIL"
      exitFailure
