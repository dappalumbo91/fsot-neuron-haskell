# FSOT NEURON Haskell

**Fluid Spacetime Omni-Theory (FSOT) neural mind — Haskell twin of the Zig domain engine.**

| | |
|--|--|
| **Zig authority** | `I:\fsot-neuron-zig` · [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **This repo** | Desktop · `FSOT NEURON haskell` |
| **Law pin** | D1D38A · \(S=K(T_1+T_2+T_3)\) |
| **Genetics** | 64-codon trinary · ORF → expression → phenotype → FI |
| **Product gate** | Full Allen ISI distribution KS (`isi-ks`) |

This is **not** a second theory. Same fold, same codon spine, same Allen readout doctrine. Zig remains bare-metal / full organism authority until this port is extended and measured.

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

## Prerequisites

Install a Haskell toolchain (not present on the lab host when this tree was created):

```powershell
# Option A: GHCup (recommended)
# https://www.haskell.org/ghcup/
ghcup install ghc
ghcup install cabal
ghcup set ghc
```

Or use [Chocolatey](https://community.chocolatey.org/packages/ghc) / Stack if you prefer.

## Build & run

```powershell
cd "$env:USERPROFILE\Desktop\FSOT NEURON haskell"

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

## Product claim (target)

After `isi-ks` is green:

```text
FSOT_ALLEN_ISI_KS_PRODUCT PASS
FSOT_ALLEN_ISI_DISTRIBUTION_OK
FSOT_KS_VS_ALLEN_CSV_OK
FSOT_GENETIC_ISI_KS_OK
FSOT_HASKELL_ISI_KS_OK
```

Cross-check against Zig:

```powershell
cd I:\fsot-neuron-zig
.\zig-out\bin\fsot_mind.exe isi-ks
```

## Port status

See [`docs/PORT_FROM_ZIG.md`](docs/PORT_FROM_ZIG.md).  
v0.1 = genetics spine + FI + ISI KS product scaffold.  
Next: Fixed lattice FI step, every-cell Allen, intel-loop / think, compose.

## License

Apache-2.0 (same family as the Zig mind).
