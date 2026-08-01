# Full capability parity — Zig authority

**Doctrine (binding):** Haskell and Idris twins are **full capable copies** of
`fsot-neuron-zig`, not demos of a single product gate.

| Twin | Repo | Role |
|------|------|------|
| **Zig** | [fsot-neuron-zig](https://github.com/dappalumbo91/fsot-neuron-zig) | Authority: Fixed SCALE=1e12, QEMU bare metal, Windows host I/O |
| **Haskell** | [fsot-neuron-haskell](https://github.com/dappalumbo91/fsot-neuron-haskell) | Host twin: every mode + module mirror; same science gates |
| **Idris2** | [fsot-neuron-idris](https://github.com/dappalumbo91/fsot-neuron-idris) | Host twin + path to type-level claims; every mode + module mirror |

## What “full capable” means

1. **Mode surface** — every `fsot_mind <mode>` in Zig has a twin CLI mode.  
2. **Module surface** — every `src/*.zig` authority module has a twin module.  
3. **Gates** — same product lines when measured (`PASS` / same units).  
4. **Honest incomplete** — until a module is green, mode returns
   `FSOT_PORT_IN_PROGRESS` with the Zig path reference — never silent no-op.

## Zig inventory

- **~119** Zig source modules under `src/`  
- **~100+** CLI modes in `main_mind.zig`  
- Surfaces: genetics · ephys · organism · intel · think · language · host I/O · GPU · QEMU

See `docs/ZIG_MODULE_INVENTORY.txt` (generated from Zig tree).

## Capability layers (port order)

| Layer | Zig examples | Twin status target |
|-------|----------------|--------------------|
| L0 Law / lattice | fixed, trit, seeds, scalar | Implemented |
| L1 Genetics | codon, genotype, genetic, cell_types | Implemented |
| L2 Ephys product | bio_probe, scalpel, allen_*, genetic_var | Implemented / green isi-ks |
| L3 Neuron body | neuron, network, brain, organism | Core port in progress |
| L4 Memory / learn | memory, learning, teach, curriculum | Core port in progress |
| L5 Intel bio | neuromod, sleep, claim, compose, intel_loop | Core port in progress |
| L6 Think / school | internal_think, brain_learn, self_study | Port next |
| L7 Language / speech | lexicon, speech, tts, machine_lang | Port next |
| L8 Embodiment | host_senses, host_loop, bio_io | Host stubs then real |
| L9 Bare metal | main_kernel, serial, QEMU | Zig-only unless freestanding target |

## Measuring parity

```text
zig:      fsot_mind stress | suite | fixed | intel-loop | think | isi-ks
haskell:  fsot-mind parity | stress | suite | fixed | intel-loop | think | isi-ks
idris:    fsot-mind parity | stress | suite | fixed | intel-loop | think | isi-ks
```

`parity` mode prints module/mode coverage table (implemented vs stub).

## Non-claims until green

- Twin numbers are **shipping claims** only after that twin’s gate prints PASS.  
- Windows GDI/mic/TTS may use host backends; Zig remains reference plant.  
- QEMU Multiboot kernel is Zig authority unless a twin freestanding target lands.
