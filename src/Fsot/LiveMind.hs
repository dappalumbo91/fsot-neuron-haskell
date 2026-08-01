-- | ONE connected organism stays online (Zig mind / Python brain twin).
module Fsot.LiveMind
  ( runLiveMind
  , runLiveMindAuto
  ) where

import Control.Monad (when)
import Data.Char (toLower)
import Data.List (find, isInfixOf, isPrefixOf)
import qualified Fsot.GliaFixed as Glia
import System.IO (hFlush, stdout)
import Text.Printf (printf)

data Cell = Pyr | Pv | Sst | Vip deriving (Eq, Show)

data Unit = Unit
  { uCell :: Cell
  , uS :: Double
  , uAdapt :: Double
  , uThr :: Double
  , uRef :: Int
  , uSpikes :: Int
  }

data Engram = Engram
  { eCue :: String
  , eAns :: String
  , eStr :: Double
  }

data Mind = Mind
  { mUnits :: [Unit]
  , mEngrams :: [Engram]
  , mGlia :: Glia.GliaState
  , mTick :: Int
  , mSpikes :: Int
  , mEncode :: Int
  , mRetr :: Int
  , mSelf :: Int
  , mSleep :: Int
  , mDa :: Double
  , mAch :: Double
  , mIdea :: String
  , mAlive :: Bool
  }

boot :: Mind
boot =
  let mix = replicate 20 Pyr ++ replicate 5 Pv ++ replicate 4 Sst ++ replicate 3 Vip
      units =
        [ Unit c (0.2 + 0.05 * fromIntegral (i `mod` 5)) 0 (0.9 + 0.02 * fromIntegral (i `mod` 4)) 0 0
        | (i, c) <- zip [0 :: Int ..] (take 32 mix)
        ]
      seeds =
        [ ("dog", "animal")
        , ("water", "liquid")
        , ("sun", "star")
        , ("plants need", "sun")
        , ("people need", "water")
        , ("sky color", "blue")
        , ("grass color", "green")
        , ("I can learn", "true")
        , ("one and one", "two")
        , ("half of ten", "five")
        ]
      eng = [Engram c a 1.0 | (c, a) <- seeds]
   in Mind units eng Glia.initGlia 0 0 (length seeds) 0 0 0 0.2 0.3 "" True

teach :: Mind -> String -> String -> Mind
teach m cue ans =
  case break ((== cue) . eCue) (mEngrams m) of
    (pre, e : post) ->
      m
        { mEngrams = pre ++ [e {eAns = ans, eStr = min 2.0 (eStr e + 0.2)}] ++ post
        , mEncode = mEncode m + 1
        }
    _ ->
      m
        { mEngrams = Engram cue ans 1.0 : mEngrams m
        , mEncode = mEncode m + 1
        }

retrieve :: Mind -> String -> (Mind, String, Bool)
retrieve m cue =
  case find (\e -> eCue e == cue || cue `isInfixOf` eCue e || eCue e `isInfixOf` cue) (mEngrams m) of
    Just e ->
      let e' = e {eStr = min 2.0 (eStr e + 0.05)}
          eng' = map (\x -> if eCue x == eCue e then e' else x) (mEngrams m)
       in (m {mEngrams = eng', mRetr = mRetr m + 1}, eAns e, True)
    Nothing -> (m, "", False)

stepNeurons :: Mind -> Double -> Mind
stepNeurons m drive =
  let eta = Glia.plasticityGain (mGlia m) 0
      stepOne u =
        if uRef u > 0
          then (u {uRef = uRef u - 1, uS = uS u * 0.5}, False)
          else
            let bias = case uCell u of
                  Pv -> 1.8
                  Sst -> 0.9
                  _ -> 1.0
                stim = drive * bias * (0.9 + 0.1 * mAch m) - 0.3 * uAdapt u
                s' = uS u * 0.88 + stim * 0.35 * eta
             in if s' >= uThr u
                  then
                    let ref = if uCell u == Pv then 3 else 8
                     in (u {uS = 0, uAdapt = uAdapt u + 0.08, uRef = ref, uSpikes = uSpikes u + 1}, True)
                  else (u {uS = s', uAdapt = uAdapt u * 0.99}, False)
      pairs = map stepOne (mUnits m)
      units' = map fst pairs
      fired = map snd pairs
      nFire = length (filter id fired)
      glia' = Glia.stepAfterSpikes (mGlia m) fired
   in m {mUnits = units', mGlia = glia', mSpikes = mSpikes m + nFire}

selfTalk :: Mind -> Mind
selfTalk m
  | null (mEngrams m) = m
  | otherwise =
      let e = mEngrams m !! (mTick m `mod` length (mEngrams m))
          (m1, ans, ok) = retrieve m (eCue e)
       in if ok
            then
              let m2 = teach m1 ("self:" ++ eCue e) ans
               in m2
                    { mSelf = mSelf m2 + 1
                    , mDa = min 0.9 (mDa m2 + 0.05)
                    , mIdea = "I know " ++ eCue e ++ " is " ++ ans
                    }
            else m1

sleepNrem :: Mind -> Mind
sleepNrem m =
  let m0 = m {mSleep = mSleep m + 1, mAch = max 0.1 (mAch m * 0.5)}
      top = take 6 (mEngrams m0)
      step3 o = iterate (`stepNeurons` 0.25) o !! 3
      m1 = foldl (\o e -> teach (step3 o) (eCue e) (eAns e)) m0 top
   in m1 {mAch = min 0.5 (mAch m1 + 0.15), mDa = max 0.15 (mDa m1 * 0.9)}

statusLine :: Mind -> String
statusLine m =
  let meanS =
        if null (mUnits m)
          then 0
          else sum (map uS (mUnits m)) / fromIntegral (length (mUnits m))
      sup = sum (Glia.gSupply (mGlia m)) / fromIntegral (length (Glia.gSupply (mGlia m)))
   in printf
        "mind t=%d spikes=%d enc=%d retr=%d selftalk=%d sleep=%d eng=%d da=%.2f ach=%.2f glia_sup=%.2f surges=%d meanS=%.3f idea=\"%s\""
        (mTick m)
        (mSpikes m)
        (mEncode m)
        (mRetr m)
        (mSelf m)
        (mSleep m)
        (length (mEngrams m))
        (mDa m)
        (mAch m)
        sup
        (Glia.gSurges (mGlia m))
        meanS
        (take 40 (mIdea m))

tickOnce :: Mind -> Mind
tickOnce m =
  let t = mTick m + 1
      phase = fromIntegral (t `mod` 40) / 40.0
      drive = 0.35 + 0.4 * abs (phase - 0.5) * 2 + 0.1 * mDa m
      m1 = stepNeurons (m {mTick = t}) drive
      m2 = if t `mod` 15 == 0 then selfTalk m1 else m1
      m3 = if t `mod` 50 == 0 then sleepNrem m2 else m2
   in m3
        { mDa = max 0.1 (mDa m3 * 0.995)
        , mAch = min 0.6 (mAch m3 * 0.998 + 0.001)
        }

strip :: String -> String
strip = reverse . dropWhile (== ' ') . reverse . dropWhile (== ' ')

handleCmd :: Mind -> String -> IO (Mind, Bool)
handleCmd m raw = do
  let cmd = strip raw
      low = map toLower cmd
  case () of
    _
      | low `elem` ["q", "quit", "exit", "stop"] ->
          pure (m {mAlive = False}, False)
      | low `elem` ["status", "st"] -> do
          putStrLn (statusLine m)
          pure (m, True)
      | low == "sleep" -> do
          putStrLn "  [sleep NREM] consolidated"
          pure (sleepNrem m, True)
      | "ask " `isPrefixOf` low -> do
          let cue = drop 4 cmd
              (m', ans, ok) = retrieve m cue
          putStrLn $ "  [retrieve] " ++ cue ++ " -> " ++ if ok then ans else "???"
          pure (if ok then selfTalk m' else m', True)
      | "teach " `isPrefixOf` low -> do
          let body = drop 6 cmd
          case break (== '=') body of
            (c, '=' : a) -> do
              let m' = teach m (strip c) (strip a)
              putStrLn $ "  [encode] " ++ strip c ++ " -> " ++ strip a
              pure (m', True)
            _ -> do
              putStrLn "  usage: teach cue=answer"
              pure (m, True)
      | low == "help" -> do
          putStrLn "  ask <cue> | teach <cue>=<ans> | sleep | status | quit | (empty=continue)"
          pure (m, True)
      | null cmd -> pure (m, True)
      | otherwise -> do
          let (m', ans, ok) = retrieve m cmd
          putStrLn $ "  [retrieve] " ++ cmd ++ " -> " ++ if ok then ans else "???"
          pure (m', True)

printBoot :: Mind -> IO ()
printBoot m = do
  putStrLn "=== FSOT LIVE MIND (connected organism - Haskell twin) ==="
  putStrLn "doctrine: ONE brain stays online - genetic + engrams + glia + self-talk + sleep"
  printf "brain units=%d engrams=%d glia_tiles=%d\n" (length (mUnits m)) (length (mEngrams m)) (length (Glia.gSupply (mGlia m)))
  putStrLn "commands: ask <cue> | teach <cue>=<ans> | sleep | status | quit | empty=continue"
  putStrLn ""

printDone :: Mind -> IO ()
printDone m = do
  putStrLn ""
  putStrLn "=== LIVE MIND STOPPED (same organism) ==="
  putStrLn (statusLine m)
  putStrLn "FSOT_CONNECTED_ORGANISM_OK"
  putStrLn "FSOT_NOT_DISCONNECTED_GATES"
  putStrLn "FSOT_LIVE_MIND_HASKELL_OK"

runLiveMindAuto :: Int -> IO ()
runLiveMindAuto maxTicks = do
  let m0 = boot
  printBoot m0
  let go m
        | mTick m >= maxTicks = pure m
        | otherwise =
            let m' = tickOnce m
             in do
                  when (mTick m' `mod` 20 == 0) $ putStrLn (statusLine m')
                  when (mTick m' `mod` 50 == 0) $
                    putStrLn $
                      "  [sleep NREM #" ++ show (mSleep m') ++ "]"
                  go m'
  mF <- go m0
  printDone mF

runLiveMind :: IO ()
runLiveMind = do
  let m0 = boot
  printBoot m0
  let loop m = do
        let m1 = tickOnce m
        if not (mAlive m1)
          then printDone m1
          else
            if mTick m1 `mod` 20 == 0
              then do
                putStrLn (statusLine m1)
                when (mTick m1 `mod` 50 == 0) $
                  putStrLn $
                    "  [sleep NREM #" ++ show (mSleep m1) ++ "]"
                putStr "live> "
                hFlush stdout
                line <- getLine
                (m2, cont) <- handleCmd m1 line
                if mAlive m2 && cont then loop m2 else printDone m2
              else loop m1
  loop m0
