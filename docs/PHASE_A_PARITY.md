# Phase A — unequivocable twin parity (Zig authority)

**Date:** 2026-08-01  
**Doctrine:** twins must be **functionally runnable equals** of Zig Phase A, not stubs.

## Phase A gate order (all three trees)

| Step | Zig mode | Haskell | Idris |
|------|----------|---------|-------|
| A0 Genetic DNA/trinary | fixed / genetic | genetic (in suite) | genetic (in phase-a) |
| A1 Continuous organism | organism | organism | organism |
| A2 Compose | compose | compose | compose |
| A3 Intel-loop | intel-loop | intel-loop | intel-loop |
| A4 Think (continuous) | think | think | think |
| A5 ISI KS product | isi-ks | isi-ks (Haskell phase-a) | port next |

## Measured green (lab)

### Haskell (`fsot-mind phase-a`)

```text
FSOT_ORGANISM PASS
FSOT_COMPOSE_INTEL PASS
FSOT_INTEL_LOOP PASS
FSOT_INTERNAL_THINK PASS  (continuous organism)
FSOT_ALLEN_ISI_KS_PRODUCT PASS
FSOT_PHASE_A PASS
```

### Idris (`fsot-mind phase-a`)

```text
FSOT_GENETIC_CORE PASS  (DNA→trinary→FSOT)
FSOT_ORGANISM PASS
FSOT_COMPOSE_INTEL PASS
FSOT_INTEL_LOOP PASS
FSOT_INTERNAL_THINK PASS
FSOT_PHASE_A PASS
```

### Zig authority (reference)

```text
compose · intel-loop · think · isi-ks · allen-bare · fixed
```

## Honest remaining gaps

- Not every Zig CLI mode (100+) is green on twins yet — **Phase A is**.  
- think-hour wall-clock 60 min is implemented on Haskell; Idris probe only.  
- QEMU bare metal remains Zig-only.  
- Host GDI/mic/TTS remain Zig-primary.

## Re-run

```powershell
# Haskell
cd "$env:USERPROFILE\Desktop\FSOT NEURON haskell"
cabal run fsot-mind -- phase-a

# Idris (WSL)
wsl --exec bash -c "export PATH=/root/.local/bin:`$PATH; cd '/mnt/c/Users/damia/Desktop/FSOT NEURON idris'; ./build/exec/fsot-mind phase-a"
```
