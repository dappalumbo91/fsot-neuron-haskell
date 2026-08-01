# FSOT language twins network

**One mind doctrine. Three programming languages. Same function. Same accuracy gates.**

Canonical copy also in:

- [fsot-neuron-zig/docs/LANGUAGE_TWINS_NETWORK.md](https://github.com/dappalumbo91/fsot-neuron-zig/blob/main/docs/LANGUAGE_TWINS_NETWORK.md)
- [fsot-neuron-idris/docs/LANGUAGE_TWINS_NETWORK.md](https://github.com/dappalumbo91/fsot-neuron-idris/blob/main/docs/LANGUAGE_TWINS_NETWORK.md)

---

## The three repositories

| Role | Language | GitHub |
|------|----------|--------|
| **Authority** | Zig | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **This host twin** | Haskell | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) |
| **Host twin + types** | Idris 2 | [fsot-neuron-idris](https://github.com/dappalumbo91/fsot-neuron-idris) |

```text
                    FSOT law pin D1D38A
                           |
         +-----------------+-----------------+
         |                 |                 |
   [Zig authority]   [Haskell twin]    [Idris twin]
   Fixed + QEMU      Phase A + isi-ks  Phase A + DNA types
         |                 |                 |
         +-------- same product function ----+
```

## Twin requirements

| Requirement | Meaning |
|-------------|---------|
| Same law | Pin D1D38A; not three theories |
| Same genetics | 64-codon PRIMARY; ORF → phenotype → FI |
| Same units | ISI ms, rate Hz, adapt abs |
| Same Phase A | organism → compose → intel-loop → think → isi-ks |
| Runnable | `cabal run fsot-mind -- phase-a` |

## Accuracy (this twin, measured)

```text
cabal run fsot-mind -- phase-a
→ FSOT_ORGANISM PASS
→ FSOT_COMPOSE_INTEL PASS
→ FSOT_INTEL_LOOP PASS
→ FSOT_INTERNAL_THINK PASS
→ FSOT_ALLEN_ISI_KS_PRODUCT PASS
→ FSOT_PHASE_A PASS
```

Cross-check Zig: `fsot_mind compose` · `intel-loop` · `think` · `isi-ks`  
Cross-check Idris: `./build/exec/fsot-mind phase-a`

See also: [`PHASE_A_PARITY.md`](PHASE_A_PARITY.md) · [`FULL_CAPABILITY_PARITY.md`](FULL_CAPABILITY_PARITY.md)
