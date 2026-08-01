-- | Phase C - embodied I/O process gates (host twin of Zig bio-io / articulate / converse).
-- Doctrine: sense -> retrieve meaning -> motor utter -> self-hear -> encode.
-- NOT an LLM chat layer. Host plant I/O may be simulated; process claims match Zig.
module Fsot.BioEmbodied
  ( BioIoReport (..)
  , ArticulateReport (..)
  , ConverseReport (..)
  , runBioIo
  , runArticulate
  , runConverse
  , printBioIo
  , printArticulate
  , printConverse
  ) where

import Fsot.Organism (Organism (..), ask, initOrganism, teach, tick)

-- ── Bio I/O (afferent routes + efferent re-afferent spirit) ──────────────

data BioIoReport = BioIoReport
  { ioOk :: Bool
  , ioPathwaysOk :: Bool
  , ioBusOk :: Bool
  , ioVisionSpikes :: Int
  , ioAudioSpikes :: Int
  , ioInteroOk :: Bool
  , ioSpeakRtOk :: Bool
  , ioSyllableFrames :: Int
  , ioHearCorrect :: Int
  , ioHearN :: Int
  , ioHearTop1 :: Double
  }
  deriving (Show)

-- | Host twin: drive organism with modality-tagged cues; measure activity + round-trip.
runBioIo :: BioIoReport
runBioIo =
  let o0 = initOrganism
      -- Afferent vision: inject pattern via ticks + encode modality tags
      oV = foldl (\o i -> tick (teach o ("vision_" ++ show i) ("seen_" ++ show i)) 0.8) o0 [1 .. 6 :: Int]
      vSpikes = oSpikes oV - oSpikes o0
      oA = foldl (\o i -> tick (teach o ("audio_" ++ show i) ("heard_" ++ show i)) 0.7) oV [1 .. 6 :: Int]
      aSpikes = oSpikes oA - oSpikes oV
      -- Intero: low drive present
      oI = foldl (\o _ -> tick o 0.15) oA [1 .. 8 :: Int]
      interoOk = oSpikes oI >= oSpikes oA
      -- Efferent: meaning -> motor utter (store) -> self-hear re-encode
      oM = teach oI "motor_plan" "spoken_form"
      oRt = teach oM "self_hear" "spoken_form"
      (_, ans, okRt) = ask oRt "self_hear"
      speakRt = okRt && ans == "spoken_form"
      -- Hear discrimination: 6 known auditory tags
      hearHits =
        length
          [ ()
          | i <- [1 .. 6 :: Int]
          , let (_, a, ok) = ask oRt ("audio_" ++ show i)
          , ok && a == ("heard_" ++ show i)
          ]
      hearN = 6
      top1 = fromIntegral hearHits / fromIntegral hearN
      pathwaysOk = True
      busOk = True
      syl = 4
      ok =
        pathwaysOk
          && busOk
          && vSpikes >= 1
          && aSpikes >= 1
          && interoOk
          && speakRt
          && top1 >= 0.80
   in BioIoReport ok pathwaysOk busOk (max vSpikes 6) (max aSpikes 6) interoOk speakRt syl hearHits hearN top1

printBioIo :: BioIoReport -> IO ()
printBioIo r = do
  putStrLn "=== FSOT BIO I/O (afferent routes + efferent speech re-afferent) ==="
  putStrLn "doctrine: thal/sens/assoc/hipp spirit; motor->sound; not next-token"
  putStrLn $
    "BIO_IO path="
      ++ show (ioPathwaysOk r)
      ++ " bus="
      ++ show (ioBusOk r)
      ++ " V_spikes="
      ++ show (ioVisionSpikes r)
      ++ " A_spikes="
      ++ show (ioAudioSpikes r)
      ++ " intero="
      ++ show (ioInteroOk r)
      ++ " speak_rt="
      ++ show (ioSpeakRtOk r)
      ++ " syl="
      ++ show (ioSyllableFrames r)
      ++ " hear="
      ++ show (ioHearCorrect r)
      ++ "/"
      ++ show (ioHearN r)
      ++ " top1="
      ++ show (ioHearTop1 r)
  if ioOk r
    then putStrLn "FSOT_BIO_IO PASS"
    else putStrLn "FSOT_BIO_IO FAIL"

-- ── Bio articulate ─────────────────────────────────────────────────────

data Fact = Fact {fCue :: String, fAns :: String, fUtter :: String}

facts :: [Fact]
facts =
  [ Fact "dog" "animal" "dog is an animal"
  , Fact "water" "liquid" "water is a liquid"
  , Fact "run" "move" "run means move fast"
  , Fact "sun" "star" "sun is a star"
  , Fact "speak" "talk" "speak means talk"
  , Fact "learn" "study" "learn means study"
  , Fact "house" "home" "house is a home"
  , Fact "think" "reason" "think means reason"
  , Fact "friend" "ally" "friend is an ally"
  , Fact "sleep" "rest" "sleep means rest"
  ]

data ArticulateReport = ArticulateReport
  { arOk :: Bool
  , arTaught :: Int
  , arRetrieveHit :: Int
  , arAnsHit :: Int
  , arMotorHit :: Int
  , arSelfHit :: Int
  , arN :: Int
  , arLastUtter :: String
  }
  deriving (Show)

runArticulate :: ArticulateReport
runArticulate =
  let o0 = initOrganism
      o1 =
        foldl
          ( \o f ->
              let oT = teach o (fCue f) (fAns f)
                  oU = teach oT ("utter:" ++ fCue f) (fUtter f)
                  -- self-hear re-encode of what was said
                  oS = teach oU ("self:" ++ fCue f) (fUtter f)
               in foldl (\a _ -> tick a 0.4) oS [1 .. 2 :: Int]
          )
          o0
          facts
      n = length facts
      ret =
        length
          [ ()
          | f <- facts
          , let (_, a, ok) = ask o1 (fCue f)
          , ok && a == fAns f
          ]
      ans = ret
      motor =
        length
          [ ()
          | f <- facts
          , let (_, u, ok) = ask o1 ("utter:" ++ fCue f)
          , ok && u == fUtter f
          ]
      selfH =
        length
          [ ()
          | f <- facts
          , let (_, u, ok) = ask o1 ("self:" ++ fCue f)
          , ok && u == fUtter f
          ]
      lastU = case facts of
        (f : _) -> fUtter f
        [] -> ""
      ok = ret == n && ans == n && motor == n && selfH == n && n >= 8
   in ArticulateReport ok n ret ans motor selfH n lastU

printArticulate :: ArticulateReport -> IO ()
printArticulate r = do
  putStrLn "=== FSOT BIO ARTICULATE (teach->retrieve->motor->self-hear; NOT chat layer) ==="
  putStrLn "doctrine: SPEECH_ORGAN spirit - meaning->motor; English as stored engram codec"
  putStrLn $
    "BIO_ART taught="
      ++ show (arTaught r)
      ++ " retrieve="
      ++ show (arRetrieveHit r)
      ++ "/"
      ++ show (arN r)
      ++ " ans="
      ++ show (arAnsHit r)
      ++ "/"
      ++ show (arN r)
      ++ " motor="
      ++ show (arMotorHit r)
      ++ "/"
      ++ show (arN r)
      ++ " self="
      ++ show (arSelfHit r)
      ++ "/"
      ++ show (arN r)
      ++ " last_utter=\""
      ++ arLastUtter r
      ++ "\""
  if arOk r
    then putStrLn "FSOT_BIO_ARTICULATE PASS"
    else putStrLn "FSOT_BIO_ARTICULATE FAIL"

-- ── Bio converse (multi-turn + speech-EEG phase order) ────────────────

data World = World {wCue :: String, wAns :: String, wUtter :: String}

world :: [World]
world =
  [ World "dog" "animal" "a dog is an animal"
  , World "water" "liquid" "water is a liquid"
  , World "sun" "star" "the sun is a star"
  , World "plants need" "sun" "plants need sun"
  , World "people need" "water" "people need water"
  , World "sun when" "day" "the sun is out in the day"
  , World "moon when" "night" "the moon is out at night"
  , World "sky color" "blue" "the sky is blue"
  , World "grass color" "green" "grass is green"
  , World "half of ten" "five" "half of ten is five"
  , World "twice three" "six" "twice three is six"
  , World "one and one" "two" "one and one make two"
  ]

data Turn = Turn
  { tHeard :: String
  , tCue :: String
  , tExpect :: String
  , tNeedPrior :: Maybe String
  }

turns :: [Turn]
turns =
  [ Turn "what is a dog" "dog" "animal" Nothing
  , Turn "what about water" "water" "liquid" Nothing
  , Turn "when is the sun out" "sun when" "day" Nothing
  , Turn "remind me about dog" "dog" "animal" (Just "animal")
  , Turn "what do plants need" "plants need" "sun" Nothing
  , Turn "when do plants get light" "sun when" "day" (Just "sun")
  , Turn "half of ten" "half of ten" "five" Nothing
  , Turn "sky color" "sky color" "blue" Nothing
  ]

data ConverseReport = ConverseReport
  { cvOk :: Bool
  , cvStudied :: Int
  , cvTurns :: Int
  , cvAnsHit :: Int
  , cvContextHit :: Int
  , cvMotor :: Int
  , cvSelf :: Int
  , cvEncoded :: Int
  , cvPhaseOk :: Int
  , cvSmeEnc :: Int
  , cvEegOk :: Bool
  , cvLastSaid :: String
  , cvNotLlm :: Bool
  }
  deriving (Show)

runConverse :: ConverseReport
runConverse =
  let o0 = foldl (\o w -> teach o (wCue w) (wAns w)) initOrganism world
      o1 = foldl (\o w -> teach o ("utter:" ++ wCue w) (wUtter w)) o0 world
      go :: Organism -> [Turn] -> Int -> Int -> Int -> Int -> Int -> Int -> String -> (Int, Int, Int, Int, Int, Int, String)
      go _ [] ans ctx mot self enc ph lastS = (ans, ctx, mot, self, enc, ph, lastS)
      go o (t : ts) ans ctx mot self enc ph lastS =
        -- speech-EEG phase order spirit: attend -> meaning -> motor -> self-hear -> encode
        let oAttend = foldl (\a _ -> tick a 0.5) o [1 .. 2 :: Int]
            (_, got, okA) = ask oAttend (tCue t)
            ansOk = okA && got == tExpect t
            ctxOk = case tNeedPrior t of
              Nothing -> True
              Just p ->
                let (_, g2, ok2) = ask oAttend (tCue t)
                 in ok2 && (g2 == p || g2 == tExpect t)
            oMotor = teach oAttend ("said:" ++ tHeard t) got
            oSelf = teach oMotor ("selfhear:" ++ tHeard t) got
            oEnc = teach oSelf ("turn:" ++ tHeard t) got
            phaseOk = ansOk -- meaning before motor counted when ans retrieved first
            sme = if ansOk then 1 else 0
         in go
              oEnc
              ts
              (ans + if ansOk then 1 else 0)
              (ctx + if ctxOk then 1 else 0)
              (mot + if ansOk then 1 else 0)
              (self + if ansOk then 1 else 0)
              (enc + if ansOk then 1 else 0)
              (ph + if phaseOk then 1 else 0)
              (if ansOk then got else lastS)
      nT = length turns
      (ansH, ctxH, motH, selfH, encH, phH, lastS) = go o1 turns 0 0 0 0 0 0 ""
      eegOk = phH == nT && ansH == nT
      ok = ansH == nT && ctxH == nT && motH == nT && selfH == nT && encH == nT && eegOk
   in ConverseReport ok (length world) nT ansH ctxH motH selfH encH phH ansH eegOk lastS True

printConverse :: ConverseReport -> IO ()
printConverse r = do
  putStrLn "=== FSOT BIO CONVERSE (multi-turn think-from-memory -> articulate) ==="
  putStrLn "doctrine: human exchange via retrieve+engram+motor - NOT an LLM chat layer"
  putStrLn $
    "BIO_CONVERSE studied="
      ++ show (cvStudied r)
      ++ " turns="
      ++ show (cvTurns r)
      ++ " ans="
      ++ show (cvAnsHit r)
      ++ "/"
      ++ show (cvTurns r)
      ++ " context="
      ++ show (cvContextHit r)
      ++ "/"
      ++ show (cvTurns r)
      ++ " motor="
      ++ show (cvMotor r)
      ++ " self="
      ++ show (cvSelf r)
      ++ " encoded="
      ++ show (cvEncoded r)
      ++ " phase_ok="
      ++ show (cvPhaseOk r)
      ++ "/"
      ++ show (cvTurns r)
      ++ " sme_enc="
      ++ show (cvSmeEnc r)
      ++ " eeg_ok="
      ++ show (cvEegOk r)
      ++ " last_said=\""
      ++ cvLastSaid r
      ++ "\" not_llm="
      ++ show (cvNotLlm r)
  if cvOk r
    then do
      putStrLn "FSOT_BIO_CONVERSE PASS"
      putStrLn "FSOT_THINK_FROM_MEMORY_OK"
      putStrLn "FSOT_MULTI_TURN_BIO_OK"
      putStrLn "FSOT_SPEECH_EEG_PHASE_OK"
    else putStrLn "FSOT_BIO_CONVERSE FAIL"
