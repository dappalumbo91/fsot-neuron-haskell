# Port map — Zig → Haskell

**Zig authority:** `I:\fsot-neuron-zig`  
**Haskell twin:** `Desktop\FSOT NEURON haskell`  
**Date:** 2026-08-01

Same law, same genetics-as-code doctrine, same Allen product claims.  
Haskell is a **host twin** for clarity / formal friendliness — Zig remains the bare-metal + Windows-senses authority until this port is measured green and extended.

| Zig | Haskell | Status |
|-----|---------|--------|
| `src/fixed.zig` | `src/Fsot/Fixed.hs` | Fixed SCALE=1e12 core |
| `src/trit.zig` | `src/Fsot/Trit.hs` | T={-1,0,+1} |
| `src/codon.zig` | `src/Fsot/Codon.hs` | 64-codon primary + ORF |
| `src/seeds.zig` / seeds_fixed | `src/Fsot/Seeds.hs` | φ, π, γ, η, ψ |
| `src/cell_types.zig` | `src/Fsot/CellTypes.hs` | Pyr/PV/SST/VIP |
| `src/genotype.zig` / genotype_fixed | `src/Fsot/Genotype.hs` | ORF→phenotype→FI knobs |
| `src/bio_probe_fixed.zig` | `src/Fsot/BioProbe.hs` | FI train + polish |
| `src/allen_isi_ks_product.zig` | `src/Fsot/AllenIsiKs.hs` | **ISI KS product** |
| `src/main_mind.zig` (subset) | `src/Fsot/Mind.hs` + `app/Main.hs` | modes |
| `data/allen/*` | `data/allen/*` | copied authority samples |
| `data/64_codon_trinary_map.txt` | `data/64_codon_trinary_map.txt` | copied |

## Not yet ported (Zig still sole authority)

- Full fixed-point organism / brain / intel-loop / think-hour  
- QEMU freestanding Multiboot kernel  
- Host senses (GDI/mic), TTS, GPU organ  
- Cre-class dist panel, every-cell Allen iron suite  
- Sleep / neuromod / compose intel stack  

Port those after `cabal run fsot-mind -- isi-ks` measures green and matches Zig product lines.

## Modes (v0.1)

```text
fsot-mind selftest
fsot-mind codon
fsot-mind genetic
fsot-mind scalpel
fsot-mind isi-ks
```

## Doctrine (binding)

1. No free-param FI tables — knobs from codon ORFs + class nudge + mutateOrf.  
2. Allen is **readout** (specimen polish + CSV targets), not a second theory.  
3. Native units: ISI ms, rate Hz, adapt abs.  
4. Product KS: genetic seed + soft polish → two-sample KS vs Allen sample.
