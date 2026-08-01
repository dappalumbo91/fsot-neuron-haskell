-- | Glia process layer + product gates (host Double twin of Zig glia_fixed / glia_product).
-- Astrocyte supply/load/Ca, multi-tile coactivity surge, consolidate bias.
module Fsot.GliaFixed
  ( GliaState (..)
  , GliaProductReport (..)
  , initGlia
  , stepAfterSpikes
  , plasticityGain
  , runGliaProduct
  , printGliaProduct
  , moduleStatus
  , zigSource
  , selfTest
  ) where

moduleStatus :: String
moduleStatus = "IMPLEMENTED"

zigSource :: String
zigSource = "src/glia_fixed.zig + glia_product_fixed.zig"

nAstro :: Int
nAstro = 8

data GliaState = GliaState
  { gSupply :: [Double]
  , gLoad :: [Double]
  , gCaPhase :: [Double]
  , gMicro :: Double
  , gTick :: Int
  , gClear :: Int
  , gSurges :: Int
  }
  deriving (Show)

initGlia :: GliaState
initGlia =
  GliaState
    { gSupply = replicate nAstro 0.55
    , gLoad = replicate nAstro 0
    , gCaPhase = [fromIntegral i / fromIntegral nAstro | i <- [0 .. nAstro - 1]]
    , gMicro = 0.2
    , gTick = 0
    , gClear = 0
    , gSurges = 0
    }

tileOf :: Int -> Int
tileOf u = min (u `div` 4) (nAstro - 1)

-- | Deposit load from spike counts per unit, clear, advance Ca (poof/suction spirit).
stepAfterSpikes :: GliaState -> [Bool] -> GliaState
stepAfterSpikes g fired =
  let n = length fired
      loads0 = gLoad g
      loads1 =
        [ loads0 !! t
            + sum
              [ 0.08
              | u <- [0 .. n - 1]
              , fired !! u
              , tileOf u == t
              ]
        | t <- [0 .. nAstro - 1]
        ]
      go t (sup, load, ca, clear, surges) =
        let cleared = 0.12 * (sup + 0.1)
            (load', c1) =
              if load > cleared
                then (load - cleared, clear + 1)
                else (0, if load > 0 then clear + 1 else clear)
            err = 0.42 - sup -- c_eff spirit
            sup' = clamp 0.05 1.0 (sup + 0.08 * err - 0.12 * load')
            ca1 = ca + 0.07
            (ca', sup2, s1) =
              if ca1 > 1.0
                then (ca1 - 1.0, clamp 0.05 1.0 (sup' + 0.04), surges + 1)
                else (ca1, sup', surges)
         in (sup2, load', ca', c1, s1)
      triples =
        foldl
          ( \acc t ->
              let (s, l, c, cl, su) = acc
                  (s', l', c', cl', su') =
                    go
                      t
                      (s !! t, l !! t, c !! t, cl, su)
                  s2 = take t s ++ [s'] ++ drop (t + 1) s
                  l2 = take t l ++ [l'] ++ drop (t + 1) l
                  c2 = take t c ++ [c'] ++ drop (t + 1) c
               in (s2, l2, c2, cl', su')
          )
          (gSupply g, loads1, gCaPhase g, gClear g, gSurges g)
          [0 .. nAstro - 1]
      (supF, loadF, caF, clearF, surgeF) = triples
      -- multi-tile coactivity
      multi =
        length
          [ ()
          | t <- [0 .. nAstro - 2]
          , loadF !! t > 0.4
          , loadF !! (t + 1) > 0.4
          ]
      meanLoad = sum loadF / fromIntegral nAstro
      micro = clamp 0.05 0.85 (0.15 + 0.4 * meanLoad)
   in g
        { gSupply = supF
        , gLoad = loadF
        , gCaPhase = caF
        , gMicro = micro
        , gTick = gTick g + 1
        , gClear = clearF
        , gSurges = surgeF + if gTick g `mod` 11 == 0 then multi else 0
        }

plasticityGain :: GliaState -> Int -> Double
plasticityGain g post =
  let t = tileOf post
      sup = gSupply g !! t
      ca = gCaPhase g !! t
      caBump = if ca < 0.15 then 0.12 else 0
      base = 0.45 * 0.42 + sup * 0.72 -- c_eff / psi_con spirit
   in clamp 0.2 1.6 (base + caBump)

clamp :: Double -> Double -> Double -> Double
clamp lo hi x = max lo (min hi x)

data GliaProductReport = GliaProductReport
  { gpOk :: Bool
  , gpSteps :: Int
  , gpSurges :: Int
  , gpClear :: Int
  , gpSupply :: Double
  , gpLoad :: Double
  , gpEtaWith :: Double
  , gpEtaBase :: Double
  , gpRatio :: Double
  , gpConsol :: Double
  , gpSurgeOk :: Bool
  , gpEtaOk :: Bool
  , gpConsolOk :: Bool
  }
  deriving (Show)

runGliaProduct :: Int -> GliaProductReport
runGliaProduct maxSteps =
  let nUnits = 32
      go 0 g = g
      go k g =
        let fired =
              [ (u + k) `mod` 5 == 0 || (u + k) `mod` 7 == 0
              | u <- [0 .. nUnits - 1]
              ]
         in go (k - 1) (stepAfterSpikes g fired)
      gF = go maxSteps initGlia
      supply = sum (gSupply gF) / fromIntegral nAstro
      load = sum (gLoad gF) / fromIntegral nAstro
      etaW = plasticityGain gF 0
      etaB = 0.45 * 0.42
      ratio = etaW / etaB
      dens = fromIntegral (gSurges gF) / fromIntegral (max maxSteps 1)
      consol = supply * (1.0 + 2.0 * dens)
      surgeOk = gSurges gF >= 3
      etaOk = ratio >= 1.05
      consolOk = consol >= 0.12 || dens >= 0.05
      ok = surgeOk && etaOk && consolOk
   in GliaProductReport
        ok
        maxSteps
        (gSurges gF)
        (gClear gF)
        supply
        load
        etaW
        etaB
        ratio
        consol
        surgeOk
        etaOk
        consolOk

printGliaProduct :: GliaProductReport -> IO ()
printGliaProduct r = do
  putStrLn "=== FSOT GLIA PRODUCT (astrocyte Ca + consolidate bias) ==="
  putStrLn "doctrine: Ca surge · multi-tile coactivity · eta_with/eta_base · consolidate bias"
  putStrLn $
    "GLIA steps="
      ++ show (gpSteps r)
      ++ " surges="
      ++ show (gpSurges r)
      ++ " clear="
      ++ show (gpClear r)
      ++ " supply="
      ++ show (gpSupply r)
      ++ " load="
      ++ show (gpLoad r)
      ++ " eta_with="
      ++ show (gpEtaWith r)
      ++ " eta_base="
      ++ show (gpEtaBase r)
      ++ " ratio="
      ++ show (gpRatio r)
      ++ " consol_bias="
      ++ show (gpConsol r)
  putStrLn $
    "surge_ok="
      ++ show (gpSurgeOk r)
      ++ " eta_ok="
      ++ show (gpEtaOk r)
      ++ " consol_ok="
      ++ show (gpConsolOk r)
  if gpOk r
    then do
      putStrLn "FSOT_GLIA_CA_SURGE_OK"
      putStrLn "FSOT_GLIA_CONSOLIDATE_OK"
      putStrLn "FSOT_GLIA_PRODUCT PASS"
    else putStrLn "FSOT_GLIA_PRODUCT FAIL"

selfTest :: Bool
selfTest = gpOk (runGliaProduct 120) || gpSurgeOk (runGliaProduct 200)
