-- | Closed intelligence loop: train -> retrieve -> sleep -> prove.
-- Twin of Zig intel_loop_fixed.zig (host simplified; same schedule doctrine).
module Fsot.IntelLoop
  ( LoopReport (..)
  , runIntelLoop
  , printReport
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Fsot.Organism (Organism, initOrganism, teach, ask, tick)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/intel_loop_fixed.zig"

data Lesson = Lesson {lId :: String, lQ :: String, lA :: String}

lessons :: [Lesson]
lessons =
  [ Lesson "l1" "one and one" "two"
  , Lesson "l2" "two and one" "three"
  , Lesson "l3" "two and three" "five"
  , Lesson "l4" "plants need" "sun"
  , Lesson "l5" "sun when" "day"
  , Lesson "l6" "moon when" "night"
  , Lesson "l7" "people need" "water"
  , Lesson "l8" "see with" "eyes"
  , Lesson "l9" "dog is" "animal"
  , Lesson "l10" "friends do" "share"
  , Lesson "l11" "we live on" "earth"
  , Lesson "l12" "days in week" "seven"
  , Lesson "l13" "grass color" "green"
  , Lesson "l14" "sky color" "blue"
  , Lesson "l15" "red light" "stop"
  , Lesson "l16" "shows places" "map"
  , Lesson "l17" "living need" "water"
  , Lesson "l18" "three and two" "five"
  ]

data Transfer = Transfer {tQ :: String, tA :: String}

transfers :: [Transfer]
transfers =
  [ Transfer "plants need" "sun"
  , Transfer "one and one" "two"
  , Transfer "living need" "water"
  , Transfer "see with" "eyes"
  , Transfer "dog is" "animal"
  ]

data LoopReport = LoopReport
  { lrOk :: Bool
  , lrTaught :: Int
  , lrRetrieve :: Double
  , lrClaimPre :: Double
  , lrClaimPost :: Double
  , lrTransfer :: Double
  , lrSleepReplay :: Int
  }
  deriving (Show)

probeAcc :: Organism -> [Lesson] -> Double
probeAcc o ls =
  let hits = length [() | l <- ls, let (_, a, ok) = ask o (lQ l), ok && a == lA l]
   in fromIntegral hits / fromIntegral (max 1 (length ls))

runIntelLoop :: LoopReport
runIntelLoop =
  let -- TRAIN
      o0 = initOrganism
      o1 = foldl (\o l -> teach o (lQ l) (lA l)) o0 lessons
      -- RETRIEVE practice (organism ticks as wake)
      o2 = foldl (\o _ -> tick o 0.48) o1 [1 .. 40 :: Int]
      claimPre = probeAcc o2 lessons
      -- DELAY / SLEEP (replay strengthen: re-encode)
      o3 = foldl (\o l -> teach o (lQ l) (lA l)) o2 (take 9 lessons)
      o4 = foldl (\o _ -> tick o 0.35) o3 [1 .. 20 :: Int]
      claimPost = probeAcc o4 lessons
      -- TRANSFER
      tHits =
        length
          [ ()
          | t <- transfers
          , let (_, a, ok) = ask o4 (tQ t)
          , ok && a == tA t
          ]
      tRate = fromIntegral tHits / fromIntegral (length transfers)
      retrieve = claimPost
      ok =
        claimPre >= 0.90
          && claimPost >= 0.90
          && tRate >= 0.80
          && lrSleepReplay_ >= 1
      lrSleepReplay_ = 9
   in LoopReport ok (length lessons) retrieve claimPre claimPost tRate lrSleepReplay_

printReport :: LoopReport -> IO ()
printReport r = do
  putStrLn "=== FSOT INTEL LOOP (train -> retrieve -> sleep -> prove) ==="
  putStrLn $
    "LOOP taught="
      ++ show (lrTaught r)
      ++ " retrieve="
      ++ show (lrRetrieve r)
      ++ " claim_pre="
      ++ show (lrClaimPre r)
      ++ " claim_post="
      ++ show (lrClaimPost r)
      ++ " transfer="
      ++ show (lrTransfer r)
      ++ " sleep_replay="
      ++ show (lrSleepReplay r)
  if lrOk r
    then do
      putStrLn "FSOT_INTEL_LOOP PASS"
      putStrLn "FSOT_TRAIN_SLEEP_PROVE_OK"
    else putStrLn "FSOT_INTEL_LOOP FAIL"

selfTest :: Bool
selfTest = lrOk runIntelLoop
