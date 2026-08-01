@echo off
REM Double-click to run FSOT Haskell mind (local, no server).
cd /d "%~dp0"
title FSOT Neuron Haskell
echo.
echo ============================================================
echo   FSOT NEURON HASKELL  -  local host twin
echo ============================================================
echo.

set "EXE=%~dp0bin\fsot-mind.exe"
if not exist "%EXE%" (
  echo Building fsot-mind.exe ...
  set "PATH=C:\ghcup\bin;%PATH%"
  where cabal >nul 2>&1
  if errorlevel 1 (
    echo ERROR: cabal/GHC not on PATH. Install GHCup or open a shell with cabal.
    pause
    exit /b 1
  )
  mkdir bin 2>nul
  cabal build exe:fsot-mind
  if errorlevel 1 (
    echo BUILD FAILED
    pause
    exit /b 1
  )
  for /f "delims=" %%i in ('dir /s /b "%~dp0dist-newstyle\*\fsot-mind.exe" 2^>nul') do (
    copy /Y "%%i" "%EXE%" >nul
    goto :have_exe
  )
  echo ERROR: could not find built fsot-mind.exe
  pause
  exit /b 1
)
:have_exe

echo.
echo   1 phase-a   2 phase-b   3 phase-c   4 phase-d
echo   5 glia-ca   6 self-talk 7 isi-ks    8 selftest
echo   9 bio-learn a all-product  q quit
echo.
set /p CHOICE=Select mode: 
if /i "%CHOICE%"=="q" exit /b 0
if "%CHOICE%"=="1" set MODE=phase-a
if "%CHOICE%"=="2" set MODE=phase-b
if "%CHOICE%"=="3" set MODE=phase-c
if "%CHOICE%"=="4" set MODE=phase-d
if /i "%CHOICE%"=="5" set MODE=glia-ca
if /i "%CHOICE%"=="6" set MODE=self-talk
if "%CHOICE%"=="7" set MODE=isi-ks
if "%CHOICE%"=="8" set MODE=selftest
if /i "%CHOICE%"=="9" set MODE=bio-learn
if /i "%CHOICE%"=="a" goto :all
if not defined MODE set MODE=%CHOICE%

echo.
echo Running: %MODE%
"%EXE%" %MODE%
set ERR=%ERRORLEVEL%
echo.
if %ERR%==0 (echo FSOT_OK) else (echo FAILED exit=%ERR%)
pause
exit /b %ERR%

:all
for %%m in (phase-a phase-b phase-c phase-d glia-ca self-talk) do (
  echo.
  echo ----- %%m -----
  "%EXE%" %%m
  if errorlevel 1 set ERR=1
)
if not defined ERR set ERR=0
pause
exit /b %ERR%
