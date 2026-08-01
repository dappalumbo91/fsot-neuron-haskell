# FSOT NEURON Haskell

**Fluid Spacetime Omni-Theory (FSOT) neural mind — full-capability Haskell twin of the Zig domain engine.**

| | |
|--|--|
| **Zig authority** | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **This repo** | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) |
| **Idris twin** | [fsot-neuron-idris](https://github.com/dappalumbo91/fsot-neuron-idris) |
| **Law pin** | D1D38A |
| **Doctrine** | **Full capable copy** of Zig — every module mirrored, every CLI mode registered |

**Not a demo.** See [`docs/FULL_CAPABILITY_PARITY.md`](docs/FULL_CAPABILITY_PARITY.md).

## Layout

```text
FSOT NEURON haskell/
  app/Main.hs              CLI (fsot-mind)
  src/Fsot/
    Fixed.hs               SCALE=1e12 lattice
    Trit.hs                T = {-1,0,+1}
    Codon.hs               64-codon map + ORF
    Seeds.hs               φ, π, γ, η, ψ
    CellTypes.hs           Pyr / PV / SST / VIP
    Genotype.hs            genetics-as-code FI knobs
    BioProbe.hs            FI train + specimen polish
    AllenIsiKs.hs          ISI distribution KS product
    Mind.hs                modes
  data/                    codon map + Allen samples (from Zig)
  docs/PORT_FROM_ZIG.md
  docs/CLAIMS_AND_NONCLAIMS.md
```

## Prerequisites (installed on this lab host)

| Tool | Version | Location |
|------|---------|----------|
| **GHCup** | 0.2.6+ | `C:\ghcup\bin` |
| **GHC** | 9.10.3 | `C:\ghcup\ghc\9.10.3` |
| **Cabal** | 3.16.1.0 | via GHCup |
| **Stack** | 3.11.1 | optional alternate |

New shell: ensure `C:\ghcup\bin` is on PATH (GHCup installer usually adds it for new sessions).

```powershell
$env:Path = "C:\ghcup\bin;" + $env:Path
ghc --version   # The Glorious Glasgow Haskell Compilation System, version 9.10.3
cabal --version
```

## Build & run

```powershell
cd "$env:USERPROFILE\Desktop\FSOT NEURON haskell"
# or: git clone https://github.com/dappalumbo91/fsot-neuron-haskell.git

$env:Path = "C:\ghcup\bin;" + $env:Path
cabal update
cabal build
cabal run fsot-mind -- selftest
cabal run fsot-mind -- genetic
cabal run fsot-mind -- scalpel
cabal run fsot-mind -- isi-ks
cabal test
```

### Modes (v0.1)

| Mode | Meaning |
|------|---------|
| `selftest` | Codon + genotype + KS self tests |
| `codon` | 64-codon PRIMARY gate |
| `genetic` | Class ORF → FI smoke |
| `scalpel` | PV ≫ Pyr rate order smoke |
| `isi-ks` | **Full ISI distribution KS product** (genetic seed + soft polish) |

## Product claim (measured 2026-08-01)

```text
FSOT_ALLEN_ISI_KS_PRODUCT PASS
FSOT_ALLEN_ISI_DISTRIBUTION_OK
FSOT_KS_VS_ALLEN_CSV_OK
FSOT_GENETIC_ISI_KS_OK
FSOT_HASKELL_ISI_KS_OK
```

Measured: n=256, D≈0.074, |Δmean|≈0.71 ms, quantiles closed (host Double twin of Zig Fixed).

Cross-check against Zig authority:

```powershell
cd I:\fsot-neuron-zig
.\zig-out\bin\fsot_mind.exe isi-ks
```

**GitHub:** https://github.com/dappalumbo91/fsot-neuron-haskell  
**Zig twin:** https://github.com/dappalumbo91/fsot-neuron-zig

## Port status

See [`docs/PORT_FROM_ZIG.md`](docs/PORT_FROM_ZIG.md).  
v0.1 = genetics spine + FI + **ISI KS product green**.  
Next: Fixed lattice FI step, every-cell Allen iron, intel-loop / think, compose.

## License

Apache-2.0 (same family as the Zig mind).
