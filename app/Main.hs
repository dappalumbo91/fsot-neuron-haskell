module Main where

import Fsot.Mind (runMode, usage)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> runMode "selftest"
    (m : _) -> runMode m
