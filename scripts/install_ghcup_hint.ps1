# Hint script: how to get GHC + Cabal on Windows for FSOT NEURON haskell.
# Does not install automatically (network + user consent).

Write-Host "FSOT NEURON haskell needs GHC + Cabal."
Write-Host ""
Write-Host "1) Install GHCup from https://www.haskell.org/ghcup/"
Write-Host "2) In a new terminal:"
Write-Host "     ghcup install ghc recommended"
Write-Host "     ghcup install cabal recommended"
Write-Host "     ghcup set ghc recommended"
Write-Host "3) Then:"
Write-Host "     cd `"$env:USERPROFILE\Desktop\FSOT NEURON haskell`""
Write-Host "     cabal update"
Write-Host "     cabal build"
Write-Host "     cabal run fsot-mind -- selftest"
Write-Host "     cabal run fsot-mind -- isi-ks"
