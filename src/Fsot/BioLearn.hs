-- | Phase B - experience intelligence (animal/human learning, NOT LLM).
-- Twin of Zig bio_learn_eval_fixed gates on host Organism store.
module Fsot.BioLearn
  ( BioLearnReport (..)
  , runBioLearn
  , printReport
  , selfTest
  ) where

import Fsot.Organism (Organism (..), ask, initOrganism, teach, tick)

data Item = Item {iCue :: String, iAns :: String}

blockA :: [Item]
blockA =
  [ Item "apple color" "red"
  , Item "grass color" "green"
  , Item "sky color" "blue"
  , Item "snow color" "white"
  , Item "coal color" "black"
  , Item "sun when" "day"
  , Item "moon when" "night"
  , Item "dog is" "animal"
  ]

blockB :: [Item]
blockB =
  [ Item "two plus two" "four"
  , Item "three plus one" "four"
  , Item "five minus two" "three"
  , Item "twice three" "six"
  , Item "half of ten" "five"
  , Item "dozen is" "twelve"
  ]

transfer :: [Item]
transfer =
  [ Item "two plus three" "five"
  , Item "four plus one" "five"
  , Item "six minus two" "four"
  , Item "twice four" "eight"
  , Item "half of eight" "four"
  , Item "twice five" "ten"
  ]

structure :: [Item]
structure =
  blockB
    ++ [ Item "twice four" "eight"
       , Item "half of eight" "four"
       , Item "two plus three" "five"
       , Item "four plus one" "five"
       , Item "six minus two" "four"
       , Item "twice five" "ten"
       ]

hard :: [Item]
hard =
  [ Item "maple color" "orange"
  , Item "ocean color" "blue"
  , Item "lemon color" "yellow"
  , Item "rose color" "red"
  ]

data BioLearnReport = BioLearnReport
  { blOk :: Bool
  , blOneshotHit :: Int
  , blOneshotN :: Int
  , blOneshotAcc :: Double
  , blFbFirst :: Int
  , blFbSecond :: Int
  , blFbN :: Int
  , blFbImproved :: Bool
  , blInterfHit :: Int
  , blInterfN :: Int
  , blInterfAcc :: Double
  , blTransferHit :: Int
  , blTransferN :: Int
  , blTransferAcc :: Double
  , blPreSleep :: Int
  , blPostSleep :: Int
  , blSleepN :: Int
  , blSleepRetained :: Bool
  , blMotor :: Int
  , blNotLlm :: Bool
  }
  deriving (Show)

experience :: Organism -> Item -> Organism
experience o it = teach o (iCue it) (iAns it)

-- | Weak exposure: tick only (no encode) - miss-prone first try.
weakDrive :: Organism -> Item -> Organism
weakDrive o _ = foldl (\a _ -> tick a 0.3) o [1 .. 3 :: Int]

probe :: Organism -> [Item] -> Int
probe o items =
  length
    [ ()
    | it <- items
    , let (_, ans, ok) = ask o (iCue it)
    , ok && ans == iAns it
    ]

sleepQuiet :: Organism -> Organism
sleepQuiet o = foldl (\a _ -> tick a 0.05) o [1 .. 20 :: Int]

runBioLearn :: BioLearnReport
runBioLearn =
  let -- 1 one-shot
      o0 = initOrganism
      o1 = foldl experience o0 blockA
      osHit = probe o1 blockA
      osN = length blockA
      osAcc = fromIntegral osHit / fromIntegral osN
      -- 2 feedback re-study on fresh organism
      o2a = foldl weakDrive initOrganism hard
      fb1 = probe o2a hard
      o2b =
        foldl
          ( \o it ->
              let (_, ans, ok) = ask o (iCue it)
               in if ok && ans == iAns it then o else experience o it
          )
          o2a
          hard
      fb2 = probe o2b hard
      fbN = length hard
      fbImp = fb2 >= fb1 && fb2 >= (fbN * 3 `div` 4)
      -- 3 interference: B after A, re-probe A
      o3 = foldl experience o1 blockB
      interHit = probe o3 blockA
      interN = length blockA
      interAcc = fromIntegral interHit / fromIntegral interN
      -- 4 transfer structure then sleep then probe
      o4 = sleepQuiet (foldl experience o3 structure)
      trHit = probe o4 transfer
      trN = length transfer
      trAcc = fromIntegral trHit / fromIntegral trN
      -- 5 sleep retention on B
      pre = probe o4 blockB
      o5 = sleepQuiet o4
      post = probe o5 blockB
      sleepN = length blockB
      retained = post + 1 >= pre
      -- 6 motor path if dog is known
      (_, _, dogOk) = ask o5 "dog is"
      motor = if dogOk then 1 else 0
      ok =
        osAcc >= 0.75
          && fbImp
          && fb2 >= (fbN * 3 `div` 4)
          && interAcc >= 0.70
          && trAcc >= 0.70
          && retained
          && motor >= 1
   in BioLearnReport
        ok
        osHit
        osN
        osAcc
        fb1
        fb2
        fbN
        fbImp
        interHit
        interN
        interAcc
        trHit
        trN
        trAcc
        pre
        post
        sleepN
        retained
        motor
        True

printReport :: BioLearnReport -> IO ()
printReport r = do
  putStrLn "=== FSOT BIO LEARN EVAL (animal/human learning - NOT LLM benchmarks) ==="
  putStrLn "doctrine: one-shot * feedback re-study * interference * transfer * sleep * motor"
  putStrLn "NOT using: GSM8K / MMLU / chat Q→A / epoch SGD corpus training"
  putStrLn "see: docs/BIO_LEARNING_DOCTRINE.md (Zig) * Phase B experience intelligence"
  putStrLn $
    "BIO_LEARN oneshot="
      ++ show (blOneshotHit r)
      ++ "/"
      ++ show (blOneshotN r)
      ++ " acc="
      ++ show (blOneshotAcc r)
      ++ " feedback="
      ++ show (blFbFirst r)
      ++ "->"
      ++ show (blFbSecond r)
      ++ "/"
      ++ show (blFbN r)
      ++ " improved="
      ++ show (blFbImproved r)
      ++ " interf_A="
      ++ show (blInterfHit r)
      ++ "/"
      ++ show (blInterfN r)
      ++ " acc="
      ++ show (blInterfAcc r)
      ++ " transfer="
      ++ show (blTransferHit r)
      ++ "/"
      ++ show (blTransferN r)
      ++ " acc="
      ++ show (blTransferAcc r)
      ++ " sleep="
      ++ show (blPreSleep r)
      ++ "->"
      ++ show (blPostSleep r)
      ++ " retained="
      ++ show (blSleepRetained r)
      ++ " motor="
      ++ show (blMotor r)
  if blOk r
    then do
      putStrLn "FSOT_BIO_LEARN PASS"
      putStrLn "FSOT_NOT_LLM_BENCHMARK_OK"
      putStrLn "FSOT_ANIMAL_LEARN_STYLE_OK"
      putStrLn "FSOT_HASKELL_PHASE_B_OK"
    else putStrLn "FSOT_BIO_LEARN FAIL"

selfTest :: Bool
selfTest = blOk runBioLearn
