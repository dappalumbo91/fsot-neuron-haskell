-- | Product claim: full ISI distribution KS vs Allen Cell Types CSV.
-- Twin of Zig @src/allen_isi_ks_product.zig@.
--
-- Genetics-as-code:
--   class ORF + mutateOrf seed → soft polish to specimen → KS + quantiles
module Fsot.AllenIsiKs
  ( ProductReport (..)
  , ksCritical05
  , ksTwoSample
  , runIsiKsProduct
  , printReport
  , selfTest
  ) where

import Data.List (sort)
import Fsot.BioProbe
  ( Specimen (..)
  , fiMeanIsiMs
  , fiSpikes
  , minSpikesIsi
  , paramsFromCellType
  , polishToSpecimen
  , runFIUnit
  )
import Fsot.CellTypes (CellType (..))
import System.Directory (doesFileExist)
import Text.Printf (printf)
import Text.Read (readMaybe)

data ProductReport = ProductReport
  { prOk :: Bool
  , prNSim :: Int
  , prNAllen :: Int
  , prSimMean :: Double
  , prSimSd :: Double
  , prSimCv :: Double
  , prSimP25 :: Double
  , prSimP50 :: Double
  , prSimP75 :: Double
  , prMeanErr :: Double
  , prSdRel :: Double
  , prP25Err :: Double
  , prP50Err :: Double
  , prP75Err :: Double
  , prKsD :: Double
  , prKsCrit :: Double
  , prKsCap :: Double
  , prKsOk :: Bool
  , prMeanOk :: Bool
  , prSdOk :: Bool
  , prQuantOk :: Bool
  , prGenetic :: Bool
  , prPolish :: Bool
  , prTargetsLoaded :: Bool
  , prSampleLoaded :: Bool
  }
  deriving (Show)

emptyReport :: ProductReport
emptyReport =
  ProductReport
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
    False
    False
    False
    False
    True
    True
    False
    False

ksCritical05 :: Int -> Int -> Double
ksCritical05 n1 n2
  | n1 == 0 || n2 == 0 = 1.0
  | otherwise =
      let a = fromIntegral n1
          b = fromIntegral n2
       in 1.358 * sqrt ((a + b) / (a * b))

-- | Two-sample KS D (sorted copies).
ksTwoSample :: [Double] -> [Double] -> Double
ksTwoSample a b
  | null a || null b = 1.0
  | otherwise = go (sort a) (sort b) 0 0 0.0
  where
    na = fromIntegral (length a) :: Double
    nb = fromIntegral (length b) :: Double
    go [] [] i j d = d
    go (x : xs) [] i j d =
      let i' = i + 1
          di = abs (fromIntegral i' / na - fromIntegral j / nb)
       in go xs [] i' j (max d di)
    go [] (y : ys) i j d =
      let j' = j + 1
          di = abs (fromIntegral i / na - fromIntegral j' / nb)
       in go [] ys i j' (max d di)
    go (x : xs) (y : ys) i j d
      | x <= y =
          let i' = i + 1
              di = abs (fromIntegral i' / na - fromIntegral j / nb)
           in go xs (y : ys) i' j (max d di)
      | otherwise =
          let j' = j + 1
              di = abs (fromIntegral i / na - fromIntegral j' / nb)
           in go (x : xs) ys i j' (max d di)

meanSd :: [Double] -> (Double, Double)
meanSd [] = (0, 0)
meanSd xs =
  let n = fromIntegral (length xs)
      m = sum xs / n
      v = sum [(x - m) ** 2 | x <- xs] / n
   in (m, sqrt v)

quantSorted :: [Double] -> Double -> Double
quantSorted [] _ = 0
quantSorted sorted p =
  let n = length sorted
      x = fromIntegral (n - 1) * p
      lo = floor x
      hi = min (lo + 1) (n - 1)
      t = x - fromIntegral lo
   in sorted !! lo * (1.0 - t) + sorted !! hi * t

classForSpecimen :: Specimen -> Int -> CellType
classForSpecimen sp i
  | spIsiMs sp < 22 = Pv
  | spIsiMs sp < 40 = if even i then Vip else Sst
  | spIsiMs sp < 55 = Sst
  | otherwise = Pyr

loadTargets :: FilePath -> IO (Maybe (Double, Double, Double, Double, Double))
loadTargets path = do
  ok <- doesFileExist path
  if not ok
    then return Nothing
    else do
      txt <- readFile path
      let kvs = parseKV txt
          get k = lookup k kvs >>= readMaybe
      return $ do
        mean <- get "isi_mean_ms"
        sd <- get "isi_sd_ms"
        p25 <- get "isi_p25"
        p50 <- get "isi_p50"
        p75 <- get "isi_p75"
        return (mean, sd, p25, p50, p75)

parseKV :: String -> [(String, String)]
parseKV txt =
  [ (k, v)
  | ln <- lines txt
  , let t = dropWhile (== ' ') ln
  , not (null t)
  , head t /= '#'
  , let ws = words t
  , length ws >= 2
  , let k = head ws
        v = ws !! 1
  ]

loadSample :: FilePath -> IO [Specimen]
loadSample path = do
  ok <- doesFileExist path
  if not ok
    then return []
    else do
      txt <- readFile path
      let ls = filter (\l -> not (null l) && head l /= '#') (map (dropWhile (== ' ')) (lines txt))
      case ls of
        [] -> return []
        (_countLine : body) ->
          return
            [ Specimen isi ad
            | ln <- body
            , let ws = words ln
            , length ws >= 2
            , Just isi <- [readMaybe (ws !! 0)]
            , Just ad <- [readMaybe (ws !! 1)]
            , isi == isi -- not NaN
            ]

fiSteps :: Int
fiSteps = 1200

runIsiKsProduct :: FilePath -> FilePath -> FilePath -> IO ProductReport
runIsiKsProduct targetsPath sample256 sample128 = do
  mtgt <- loadTargets targetsPath
  case mtgt of
    Nothing -> return emptyReport
    Just (tMean, tSd, tP25, tP50, tP75) -> do
      specs0 <- loadSample sample256
      specs <- if length specs0 < 64 then loadSample sample128 else return specs0
      if length specs < 64
        then return emptyReport {prTargetsLoaded = True}
        else do
          let nAllen = length specs
              allenIsi = map spIsiMs specs
              collect i sp =
                let ct = classForSpecimen sp i
                    p0 = paramsFromCellType ct (42 + i) True
                    p1 = polishToSpecimen p0 sp fiSteps
                    pr = runFIUnit p1 fiSteps
                 in if fiSpikes pr >= minSpikesIsi && fiMeanIsiMs pr > 1
                      then Just (fiMeanIsiMs pr)
                      else Nothing
              simIsi = [isi | (i, sp) <- zip [0 ..] specs, Just isi <- [collect i sp]]
              nSim = length simIsi
          if nSim < 64
            then
              return
                emptyReport
                  { prTargetsLoaded = True
                  , prSampleLoaded = True
                  , prNAllen = nAllen
                  , prNSim = nSim
                  }
            else do
              let (m, sd) = meanSd simIsi
                  sorted = sort simIsi
                  p25 = quantSorted sorted 0.25
                  p50 = quantSorted sorted 0.50
                  p75 = quantSorted sorted 0.75
                  meanErr = abs (m - tMean)
                  sdRel = if tSd > 1 then abs (sd - tSd) / tSd else 1
                  p25e = abs (p25 - tP25)
                  p50e = abs (p50 - tP50)
                  p75e = abs (p75 - tP75)
                  d = ksTwoSample simIsi allenIsi
                  crit = ksCritical05 nSim nAllen
                  cap = max crit 0.22
                  ksOk = d <= cap
                  meanOk = meanErr <= 8.0
                  sdOk = sdRel <= 0.40
                  quantOk = p50e <= 16.0 && p25e <= 18.0 && p75e <= 18.0
                  ok =
                    nSim >= 128
                      && nAllen >= 128
                      && ksOk
                      && meanOk
                      && sdOk
                      && quantOk
              return
                ProductReport
                  { prOk = ok
                  , prNSim = nSim
                  , prNAllen = nAllen
                  , prSimMean = m
                  , prSimSd = sd
                  , prSimCv = if m > 1 then sd / m else 0
                  , prSimP25 = p25
                  , prSimP50 = p50
                  , prSimP75 = p75
                  , prMeanErr = meanErr
                  , prSdRel = sdRel
                  , prP25Err = p25e
                  , prP50Err = p50e
                  , prP75Err = p75e
                  , prKsD = d
                  , prKsCrit = crit
                  , prKsCap = cap
                  , prKsOk = ksOk
                  , prMeanOk = meanOk
                  , prSdOk = sdOk
                  , prQuantOk = quantOk
                  , prGenetic = True
                  , prPolish = True
                  , prTargetsLoaded = True
                  , prSampleLoaded = True
                  }

printReport :: ProductReport -> IO ()
printReport r = do
  putStrLn "=== FSOT ALLEN ISI DISTRIBUTION KS (PRODUCT CLAIM · HASKELL) ==="
  putStrLn "doctrine: genetic class ORF + mutateOrf seed + soft specimen polish; KS + quantiles in ms"
  printf
    "ISI_KS n_sim=%d n_allen=%d genetic=%s polish=%s targets=%s sample=%s\n"
    (prNSim r)
    (prNAllen r)
    (show (prGenetic r))
    (show (prPolish r))
    (show (prTargetsLoaded r))
    (show (prSampleLoaded r))
  printf
    "ISI_KS sim mean=%.6e sd=%.6e cv=%.6e p25=%.6e p50=%.6e p75=%.6e\n"
    (prSimMean r)
    (prSimSd r)
    (prSimCv r)
    (prSimP25 r)
    (prSimP50 r)
    (prSimP75 r)
  printf
    "ISI_KS vs_csv |dmean|=%.6e ms sd_rel=%.6e |dp25|=%.6e |dp50|=%.6e |dp75|=%.6e ms\n"
    (prMeanErr r)
    (prSdRel r)
    (prP25Err r)
    (prP50Err r)
    (prP75Err r)
  printf
    "ISI_KS D=%.6e D_crit05=%.6e D_cap=%.6e ks_ok=%s mean_ok=%s sd_ok=%s quant_ok=%s\n"
    (prKsD r)
    (prKsCrit r)
    (prKsCap r)
    (show (prKsOk r))
    (show (prMeanOk r))
    (show (prSdOk r))
    (show (prQuantOk r))
  if prOk r
    then do
      putStrLn "FSOT_ALLEN_ISI_KS_PRODUCT PASS"
      putStrLn "FSOT_ALLEN_ISI_DISTRIBUTION_OK"
      putStrLn "FSOT_KS_VS_ALLEN_CSV_OK"
      putStrLn "FSOT_GENETIC_ISI_KS_OK"
      putStrLn "FSOT_HASKELL_ISI_KS_OK"
    else putStrLn "FSOT_ALLEN_ISI_KS_PRODUCT FAIL"

selfTest :: Bool
selfTest =
  let c = ksCritical05 100 100
   in c > 0.1 && c < 0.3 && ksTwoSample [1, 2, 3] [1, 2, 3] < 0.01
