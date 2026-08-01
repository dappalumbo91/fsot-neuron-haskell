# FSOT NEURON Haskell

**Fluid Spacetime Omni-Theory (FSOT) neural mind — Haskell host twin of the Zig domain engine.**

Not a second theory. Same law, same genetics-as-code, same Phase A product function, measured to the **same accuracy gates** as Zig and Idris.

---

## Language twins network (linking system)

| Role | Language | Repository |
|------|----------|------------|
| **Authority** | Zig | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) |
| **This host twin** | Haskell | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) |
| **Host twin + type structure** | Idris 2 | [fsot-neuron-idris](https://github.com/dappalumbo91/fsot-neuron-idris) |

```text
         FSOT pin D1D38A  ·  DNA/codon → trinary → FI  ·  Allen ms/Hz
                              |
              +---------------+---------------+
              |               |               |
           [Zig]          [Haskell]        [Idris]
         Fixed+QEMU     this repo        Phase A+types
              |               |               |
              +--- same function · same accuracy ---+
```

**Full linking system (read this first):**  
[`docs/LANGUAGE_TWINS_NETWORK.md`](docs/LANGUAGE_TWINS_NETWORK.md)

**Phase A parity across languages:**  
[`docs/PHASE_A_PARITY.md`](docs/PHASE_A_PARITY.md)

**Full-capability doctrine:**  
[`docs/FULL_CAPABILITY_PARITY.md`](docs/FULL_CAPABILITY_PARITY.md)

### Cross-language boot (same gates)

| Gate | Zig | This repo (Haskell) | Idris |
|------|-----|---------------------|-------|
| Continuous organism | `fsot_mind organism` | `fsot-mind organism` | `fsot-mind organism` |
| Compose | `fsot_mind compose` | `fsot-mind compose` | `fsot-mind compose` |
| Intel-loop | `fsot_mind intel-loop` | `fsot-mind intel-loop` | `fsot-mind intel-loop` |
| Think probe | `fsot_mind think` | `fsot-mind think` | `fsot-mind think` |
| ISI KS product | `fsot_mind isi-ks` | `fsot-mind isi-ks` | *port next* |
| **Phase A suite** | compose+loop+think+isi-ks | **`fsot-mind phase-a`** | **`fsot-mind phase-a`** |

---

## Measured accuracy (lab boot)

```text
cabal run fsot-mind -- phase-a

FSOT_ORGANISM PASS
FSOT_COMPOSE_INTEL PASS          claim_rate=1.0
FSOT_INTEL_LOOP PASS             claim_pre=post=1.0
FSOT_INTERNAL_THINK PASS         continuous organism
FSOT_ALLEN_ISI_KS_PRODUCT PASS   D≈0.074 |Δmean|≈0.71 ms
FSOT_PHASE_A PASS
FSOT_TWIN_PHASE_A_OK
```

Zig Fixed SCALE=1e12 remains **bit-authority** for lattice dynamics. This twin proves **functional / scientific equivalence** on the shared product gates.

---

## Prerequisites

| Tool | Version |
|------|---------|
| GHC | 9.10.3 (via GHCup) |
| Cabal | 3.16+ |

```powershell
$env:Path = "C:\ghcup\bin;" + $env:Path
```

## Build & run

```powershell
cd "$env:USERPROFILE\Desktop\FSOT NEURON haskell"
# or: git clone https://github.com/dappalumbo91/fsot-neuron-haskell.git

cabal build
cabal run fsot-mind -- phase-a      # full Phase A (recommended)
cabal run fsot-mind -- think        # continuous organism think probe
cabal run fsot-mind -- isi-ks       # Allen ISI distribution KS
cabal run fsot-mind -- selftest
cabal run fsot-mind -- parity
```

### High-signal modes

| Mode | What it tests |
|------|----------------|
| `phase-a` | Organism + compose + intel-loop + think + isi-ks |
| `think` / `think-min N` | Continuous organism think (not a full hour unless asked) |
| `intel-loop` | Train → sleep → prove |
| `compose` | Answer-dependent multi-hop |
| `isi-ks` | Full ISI distribution KS vs Allen CSV |
| `genetic` / `scalpel` | DNA/class ORF FI · PV≫Pyr |
| `organism` | Continuous tick + episodic memory |

## Layout

```text
src/Fsot/   Fixed, Trit, Codon, Genotype, BioProbe, AllenIsiKs,
            Neuron, Memory, Organism, IntelLoop, ComposeIntel,
            InternalThink, PhaseA, Mind, …
data/allen/ Allen targets + samples (shared authority with Zig)
docs/       LANGUAGE_TWINS_NETWORK · PHASE_A_PARITY · FULL_CAPABILITY_PARITY
```

## Related FSOT GitHub

| Repo | Role |
|------|------|
| [FSOT-2.1-Lean](https://github.com/dappalumbo91/FSOT-2.1-Lean) | Law / Lean |
| [FSOT-2.1-Neural](https://github.com/dappalumbo91/FSOT-2.1-Neural) | Wet-lab / banks |

## License

Apache-2.0
