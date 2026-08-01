@echo off
REM LIVE connected organism (not unit-test parade)
cd /d "%~dp0"
title FSOT Live Mind - Haskell
echo.
echo ============================================================
echo   FSOT LIVE MIND  (Haskell twin)
echo   ONE brain: units + engrams + glia + self-talk + sleep
echo ============================================================
echo.

set "EXE=%~dp0bin\fsot-mind.exe"
if not exist "%EXE%" (
  echo Building...
  set "PATH=C:\ghcup\bin;%PATH%"
  cabal build exe:fsot-mind
  if errorlevel 1 (echo BUILD FAILED & pause & exit /b 1)
  mkdir bin 2>nul
  for /f "delims=" %%i in ('dir /s /b "%~dp0dist-newstyle\*\fsot-mind.exe" 2^>nul') do (
    copy /Y "%%i" "%EXE%" >nul
    goto :run
  )
  echo ERROR: fsot-mind.exe not found
  pause
  exit /b 1
)
:run
echo Starting LIVE mind (type quit to stop)...
echo.
"%EXE%" mind
echo.
pause
