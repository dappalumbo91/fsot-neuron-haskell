-- | Self-talk re-entry (host twin of Zig self_talk_fixed).
module Fsot.SelfTalk
  ( SelfTalkReport (..)
  , runSelfTalk
  , printReport
  , selfTest
  ) where

import Fsot.Organism (ask, initOrganism, teach, tick)

data Fact = Fact {fCue :: String, fAns :: String}

seeds :: [Fact]
seeds =
  [ Fact "dog" "animal"
  , Fact "water" "liquid"
  , Fact "sun" "star"
  , Fact "I can learn" "true"
  ]

selfCues :: [(String, String, String)]
selfCues =
  [ ("what do I know about dog", "dog", "animal")
  , ("remind myself water", "water", "liquid")
  , ("I know the sun is", "sun", "star")
  , ("can I learn", "I can learn", "true")
  ]

data SelfTalkReport = SelfTalkReport
  { stOk :: Bool
  , stSeeded :: Int
  , stCues :: Int
  , stRetrieve :: Int
  , stReencode :: Int
  , stLast :: String
  }
  deriving (Show)

runSelfTalk :: SelfTalkReport
runSelfTalk =
  let o0 = foldl (\o f -> teach o (fCue f) (fAns f)) initOrganism seeds
      step o (heard, cue, expect) (ret, re, lastS) =
        let o1 = foldl (\a _ -> tick a 0.45) o [1 .. 3 :: Int]
            (_, ans, ok) = ask o1 cue
            hit = ok && ans == expect
            o2 = if hit then teach o1 ("selftalk:" ++ heard) expect else o1
         in ( o2
            , ( ret + if hit then 1 else 0
              , re + if hit then 1 else 0
              , if hit then heard else lastS
              )
            )
      (oF, (ret, re, lastS)) =
        foldl
          (\(o, acc) sc -> step o sc acc)
          (o0, (0, 0, ""))
          selfCues
      prove =
        length
          [ ()
          | f <- seeds
          , let (_, a, ok) = ask oF (fCue f)
          , ok && a == fAns f
          ]
      ok = ret >= 3 && re >= 3 && prove >= 3
   in SelfTalkReport ok (length seeds) (length selfCues) ret re lastS

printReport :: SelfTalkReport -> IO ()
printReport r = do
  putStrLn "=== FSOT SELF-TALK (internal dialogue re-entry - NOT LLM chat) ==="
  putStrLn "doctrine: covert self-cue -> retrieve meaning -> re-encode self episode"
  putStrLn $
    "SELF_TALK seeded="
      ++ show (stSeeded r)
      ++ " cues="
      ++ show (stCues r)
      ++ " retrieve="
      ++ show (stRetrieve r)
      ++ " reencode="
      ++ show (stReencode r)
      ++ " last=\""
      ++ stLast r
      ++ "\""
  if stOk r
    then do
      putStrLn "FSOT_SELF_TALK_REENCODE_OK"
      putStrLn "FSOT_SELF_TALK PASS"
    else putStrLn "FSOT_SELF_TALK FAIL"

selfTest :: Bool
selfTest = stOk runSelfTalk
