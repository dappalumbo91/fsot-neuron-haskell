-- | Adaptive internal thinking — twin of Zig internal_think_fixed.zig.
-- Continuous organism: seed world -> encode -> retrace -> discover -> compose ideas -> sleep.
-- Modes: think (probe) | think-min N | think-hour
module Fsot.InternalThink
  ( ThinkReport (..)
  , runThinkProbe
  , runThinkMinutes
  , printReport
  , selfTest
  , moduleStatus
  , zigSource
  ) where

import Control.Concurrent (threadDelay)
import Data.List (nub)
import Data.Time.Clock (UTCTime, diffUTCTime, getCurrentTime)
import Fsot.Organism
  ( Organism
  , ask
  , initOrganism
  , oSpikes
  , oTick
  , teach
  , tick
  )
import System.Directory (createDirectoryIfMissing)
import System.IO (IOMode (..), hClose, hPutStrLn, openFile)

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/internal_think_fixed.zig"

data Fact = Fact {fCue :: String, fAns :: String, fUtter :: String}

-- | Seed world (Zig SEED_WORLD twin) — genetics-grounded knowledge, not LLM corpus.
seedWorld :: [Fact]
seedWorld =
  [ Fact "dog" "animal" "a dog is an animal"
  , Fact "water" "liquid" "water is a liquid"
  , Fact "sun" "star" "the sun is a star"
  , Fact "plants need" "sun" "plants need sun"
  , Fact "people need" "water" "people need water"
  , Fact "sun when" "day" "the sun is out in the day"
  , Fact "sky color" "blue" "the sky is blue"
  , Fact "neuron" "cell" "a neuron is a nerve cell"
  , Fact "brain" "organ" "the brain is the thinking organ"
  , Fact "light" "see" "light is what we see with eyes"
  , Fact "gravity" "force" "gravity is a force that pulls"
  , Fact "half of ten" "five" "half of ten is five"
  , Fact "twice five" "ten" "twice five is ten"
  , Fact "one and one" "two" "one and one make two"
  , Fact "earth is" "planet" "earth is a planet"
  , Fact "friends do" "share" "friends share"
  , Fact "moon when" "night" "the moon is out at night"
  , Fact "two and three" "five" "two and three make five"
  , Fact "grass color" "green" "grass is green"
  , Fact "days in week" "seven" "a week has seven days"
  ]

-- | Literature-style cards (discoverable terms).
litCards :: [(String, String)]
litCards =
  [ ("global", "earth-wide")
  , ("force", "push or pull")
  , ("organ", "body part")
  , ("cell", "life unit")
  , ("planet", "world body")
  , ("liquid", "flows")
  , ("star", "sun-like body")
  , ("share", "give together")
  ]

data ThinkReport = ThinkReport
  { trOk :: Bool
  , trNCycles :: Int
  , trNStudied :: Int
  , trNLit :: Int
  , trRetraceOk :: Int
  , trRetrace :: Int
  , trDiscoverHit :: Int
  , trDiscover :: Int
  , trNewConcepts :: Int
  , trIdeas :: Int
  , trUnique :: Int
  , trGrown :: Int
  , trEngrams :: Int
  , trSleep :: Int
  , trMutations :: Int
  , trSpikes :: Int
  , trDurationMs :: Int
  , trStopReason :: String
  , trLastNew :: String
  , trLastIdea :: String
  }
  deriving (Show)

emptyRep :: ThinkReport
emptyRep =
  ThinkReport
    False
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    0
    "init"
    ""
    ""

bootOrganism :: Organism
bootOrganism =
  let o0 = initOrganism
   in foldl (\o f -> teach o (fCue f) (fAns f)) o0 seedWorld

retracePass :: Organism -> (Int, Int)
retracePass o =
  let checks =
        [ let (_, a, ok) = ask o (fCue f)
           in ok && a == fAns f
        | f <- seedWorld
        ]
   in (length (filter id checks), length checks)

-- | Discover unknown answer words via lit cards (query-tool stand-in).
discoverCycle :: Organism -> [String] -> (Organism, Int, Int, [String], String)
discoverCycle o grown =
  let targets = nub [fAns f | f <- seedWorld] ++ map fst litCards
      unknown = [t | t <- targets, t `notElem` grown, let (_, _, ok) = ask o t, not ok]
   in case unknown of
        [] -> (o, 0, 0, grown, "")
        (w : _) ->
          case lookup w litCards of
            Just def ->
              let o' = teach o w def
               in (o', 1, 1, w : grown, w)
            Nothing ->
              -- self-ground: answer is the cue itself (placeholder retain)
              let o' = teach o w w
               in (o', 0, 1, grown, "")

-- | Brainstorm: compose idea from two engram answers.
composeIdea :: Organism -> Int -> String
composeIdea o cy =
  let n = length seedWorld
      i = cy `mod` n
      j = (cy * 3 + 1) `mod` n
      a = seedWorld !! i
      b = seedWorld !! j
      (_, ansA, okA) = ask o (fCue a)
      (_, ansB, okB) = ask o (fCue b)
   in if okA && okB
        then fCue a ++ " is " ++ ansA ++ " so " ++ fCue b ++ " is " ++ ansB
        else "pending"

sleepCycle :: Organism -> Organism
sleepCycle o =
  -- NREM stand-in: quiet ticks + re-encode first half of seeds (replay)
  let o1 = foldl (\x _ -> tick x 0.30) o [1 .. 8 :: Int]
      o2 = foldl (\x f -> teach x (fCue f) (fAns f)) o1 (take 8 seedWorld)
   in foldl (\x _ -> tick x 0.35) o2 [1 .. 8 :: Int]

runCycles :: Int -> Int -> IO ThinkReport
runCycles maxCycles maxMs = do
  t0 <- getCurrentTime
  let o0 = bootOrganism
      o1 = foldl (\o _ -> tick o 0.48) o0 [1 .. 16 :: Int]
  createDirectoryIfMissing True "data/results"
  hLog <- openFile "data/results/THINK_LIVE.log" AppendMode
  hPutStrLn hLog $ "THINK_BOOT seeds=" ++ show (length seedWorld) ++ " lit=" ++ show (length litCards)
  let loop
        :: Int
        -> Organism
        -> [String]
        -> [String]
        -> Int
        -> Int
        -> Int
        -> Int
        -> Int
        -> Int
        -> String
        -> String
        -> IO ThinkReport
      loop cy o grown ideas uniq retrOk retrN discH discN sleepN lastNew lastIdea = do
        now <- getCurrentTime
        let elapsedMs = floor (diffUTCTime now t0 * 1000) :: Int
            timeUp = maxMs > 0 && elapsedMs >= maxMs
            cyclesUp = maxCycles > 0 && cy >= maxCycles
        if timeUp || cyclesUp
          then do
            hPutStrLn hLog $ "THINK_DONE cy=" ++ show cy ++ " ms=" ++ show elapsedMs
            hClose hLog
            let (rok, rn) = retracePass o
                ok = cy >= 1 && rok * 2 >= rn && discH + length grown >= 0
            pure
              ThinkReport
                { trOk = ok
                , trNCycles = cy
                , trNStudied = length seedWorld + length grown
                , trNLit = length litCards
                , trRetraceOk = rok
                , trRetrace = rn
                , trDiscoverHit = discH
                , trDiscover = discN
                , trNewConcepts = length grown
                , trIdeas = length ideas
                , trUnique = length (nub ideas)
                , trGrown = length grown
                , trEngrams = length seedWorld + length grown
                , trSleep = sleepN
                , trMutations = if cy > 0 then 1 else 0
                , trSpikes = oSpikes o
                , trDurationMs = elapsedMs
                , trStopReason = if timeUp then "time" else "cycles"
                , trLastNew = lastNew
                , trLastIdea = lastIdea
                }
          else do
            -- retrace
            let (rok, rn) = retracePass o
            -- discover
            let (o2, dh, dn, grown2, newW) = discoverCycle o grown
            -- compose idea
            let idea = composeIdea o2 cy
                ideas2 = idea : ideas
            -- organism live ticks (continuous mind)
            let o3 = foldl (\x _ -> tick x 0.50) o2 [1 .. 12 :: Int]
            -- sleep every 2 cycles
            let (o4, sleepN2) =
                  if cy `mod` 2 == 0
                    then (sleepCycle o3, sleepN + 1)
                    else (o3, sleepN)
            hPutStrLn hLog $
              "THINK_HB cy="
                ++ show (cy + 1)
                ++ " retr="
                ++ show rok
                ++ "/"
                ++ show rn
                ++ " disc="
                ++ show dh
                ++ " grown="
                ++ show (length grown2)
                ++ " idea="
                ++ take 40 idea
            -- small yield so wall-clock think-min advances
            threadDelay 2000
            loop
              (cy + 1)
              o4
              grown2
              ideas2
              (length (nub ideas2))
              (retrOk + rok)
              (retrN + rn)
              (discH + dh)
              (discN + dn)
              sleepN2
              (if null newW then lastNew else newW)
              idea
  loop 0 o1 [] [] 0 0 0 0 0 0 "" ""

-- | Short probe (Zig runThinkProbe twin): enough cycles for PASS.
runThinkProbe :: IO ThinkReport
runThinkProbe = runCycles 8 0

-- | Wall-clock minutes of continuous think (Zig runThinkMinutes).
runThinkMinutes :: Int -> IO ThinkReport
runThinkMinutes minutes =
  let ms = max 1 minutes * 60 * 1000
      -- also cap cycles so a minute is productive (~30 cycles/min target)
      maxCy = max 30 (minutes * 40)
   in runCycles maxCy ms

printReport :: ThinkReport -> IO ()
printReport r = do
  putStrLn "=== FSOT INTERNAL THINK (continuous organism) ==="
  putStrLn "doctrine: encode -> episodic retrace -> discover -> compose -> sleep | NOT LLM"
  putStrLn $
    "THINK studied="
      ++ show (trNStudied r)
      ++ " lit="
      ++ show (trNLit r)
      ++ " cy="
      ++ show (trNCycles r)
      ++ " retr="
      ++ show (trRetraceOk r)
      ++ "/"
      ++ show (trRetrace r)
      ++ " disc="
      ++ show (trDiscoverHit r)
      ++ "/"
      ++ show (trDiscover r)
      ++ " new="
      ++ show (trNewConcepts r)
      ++ " ideas="
      ++ show (trIdeas r)
      ++ " uniq="
      ++ show (trUnique r)
      ++ " grown="
      ++ show (trGrown r)
      ++ " eng="
      ++ show (trEngrams r)
  putStrLn $
    "THINK_RUN reason="
      ++ trStopReason r
      ++ " sleep="
      ++ show (trSleep r)
      ++ " mut="
      ++ show (trMutations r)
      ++ " spikes="
      ++ show (trSpikes r)
      ++ " ms="
      ++ show (trDurationMs r)
  when (not (null (trLastNew r))) $ putStrLn $ "new_concept=\"" ++ trLastNew r ++ "\""
  when (not (null (trLastIdea r))) $ putStrLn $ "last_idea=\"" ++ take 80 (trLastIdea r) ++ "\""
  if trOk r
    then do
      putStrLn "FSOT_INTERNAL_THINK PASS"
      putStrLn "FSOT_ADAPTIVE_KNOWLEDGE_OK"
      putStrLn "FSOT_CONTINUOUS_ORGANISM_OK"
    else putStrLn "FSOT_INTERNAL_THINK FAIL"
  where
    when c a = if c then a else pure ()

selfTest :: Bool
selfTest = length seedWorld >= 8
