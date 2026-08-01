# Claims and non-claims — FSOT NEURON Haskell

**Sibling of:** [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig)  
**Date:** 2026-08-01

## We claim (this repo, when measured)

| Claim | How verified |
|-------|----------------|
| 64-codon PRIMARY map AG=+1 CT=−1; ATG=[+1,−1,+1] | `fsot-mind selftest` / `codon` |
| Class ORF → phenotype → FI knobs path exists | `fsot-mind genetic` |
| Full ISI distribution KS product (genetic + polish) | `fsot-mind isi-ks` → `FSOT_ALLEN_ISI_KS_PRODUCT PASS` |

## We do **not** claim (yet)

| Non-claim | Why |
|-----------|-----|
| Bit-identical dynamics to Zig Fixed SCALE=1e12 | Haskell host FI is Double twin; Fixed module present but FI train not lattice-stepped yet |
| Every-cell Allen iron (1.42 ms / 0.00512 A) | Zig primary |
| QEMU bare-metal | Zig only |
| Full intel-loop / think-hour / compose | Port next phases |
| Peer review / AGI | Same hygiene as Zig CLAIMS |

## Relationship to Zig

Zig is the measured product authority today. This Haskell tree is a faithful structure port so the same science can be stated in a pure functional host. **Do not advertise Haskell numbers as shipping claims until they are run green and cross-checked against Zig.**
