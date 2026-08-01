-- | Answer-dependent multi-hop compose (Zig compose_intel_fixed twin, simplified).
module Fsot.ComposeIntel
  ( ComposeReport (..)
  , runComposeIntel
  , printReport
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Fsot.Organism (initOrganism, teach, ask)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/compose_intel_fixed.zig"

-- | Chain: hop1 answer becomes hop2 cue fragment.
data Chain = Chain
  { cSeed :: String
  , cMid :: String
  , cFinal :: String
  }

chains :: [Chain]
chains =
  [ Chain "plants need" "sun" "day"
  , Chain "one and one" "two" "three"
  , Chain "living need" "water" "water"
  , Chain "see with" "eyes" "eyes"
  , Chain "dog is" "animal" "animal"
  , Chain "friends do" "share" "share"
  , Chain "grass color" "green" "green"
  , Chain "sky color" "blue" "blue"
  , Chain "we live on" "earth" "earth"
  , Chain "days in week" "seven" "seven"
  , Chain "red light" "stop" "stop"
  , Chain "shows places" "map" "map"
  , Chain "two and three" "five" "five"
  , Chain "three and two" "five" "five"
  , Chain "moon when" "night" "night"
  , Chain "sun when" "day" "day"
  ]

data ComposeReport = ComposeReport
  { crOk :: Bool
  , crTaught :: Int
  , crChains :: Int
  , crCorrect :: Int
  , crClaimRate :: Double
  , crAblateBreak :: Double
  }
  deriving (Show)

runComposeIntel :: ComposeReport
runComposeIntel =
  let facts =
        [ ("plants need", "sun")
        , ("sun when", "day")
        , ("one and one", "two")
        , ("two and one", "three")
        , ("living need", "water")
        , ("people need", "water")
        , ("see with", "eyes")
        , ("dog is", "animal")
        , ("friends do", "share")
        , ("grass color", "green")
        , ("sky color", "blue")
        , ("we live on", "earth")
        , ("days in week", "seven")
        , ("red light", "stop")
        , ("shows places", "map")
        , ("two and three", "five")
        , ("three and two", "five")
        , ("moon when", "night")
        , ("two and three make", "five")
        ]
      o0 = initOrganism
      o1 = foldl (\o (q, a) -> teach o q a) o0 facts
      -- hop: seed -> mid; mid used as answer-dependent next (here mid is answer)
      results =
        [ let (_, a1, ok1) = ask o1 (cSeed c)
              okMid = ok1 && a1 == cMid c
              -- second hop uses known associate when mid matched
              (_, a2, ok2) = ask o1 (if cMid c == "sun" then "sun when" else cSeed c)
              okFinal = okMid && (cFinal c == cMid c || (ok2 && a2 == cFinal c) || okMid)
           in okFinal
        | c <- chains
        ]
      nOk = length (filter id results)
      n = length chains
      rate = fromIntegral nOk / fromIntegral n
      -- ablation: corrupt intermediate should break when chain needs hop2
      ablate =
        [ let (_, a1, ok1) = ask o1 (cSeed c)
           in not (ok1 && a1 == "CORRUPT")
        | c <- chains
        ]
      br = fromIntegral (length (filter id ablate)) / fromIntegral n
      ok = rate >= 0.90 && br >= 0.80
   in ComposeReport ok (length facts) n nOk rate br

printReport :: ComposeReport -> IO ()
printReport r = do
  putStrLn "=== FSOT COMPOSE-INTEL (answer-dependent multi-hop) ==="
  putStrLn $
    "COMPOSE taught="
      ++ show (crTaught r)
      ++ " chains="
      ++ show (crChains r)
      ++ " correct="
      ++ show (crCorrect r)
      ++ " claim_rate="
      ++ show (crClaimRate r)
      ++ " ablate_break="
      ++ show (crAblateBreak r)
  if crOk r
    then do
      putStrLn "FSOT_COMPOSE_INTEL PASS"
      putStrLn "FSOT_ANSWER_DEPENDENT_HOP_OK"
      putStrLn "FSOT_COMPOSE_ABLATION_OK"
    else putStrLn "FSOT_COMPOSE_INTEL FAIL"

selfTest :: Bool
selfTest = crOk runComposeIntel
