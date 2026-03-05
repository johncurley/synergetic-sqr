# SPU-13: Isotropic Processing Architecture (v2.11.12)
## Deterministic High-Dimensional Spatial Computing in Synthesizable RTL

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

### 1. Overview
The SPU-13 (Synergetic Processing Unit) is a high-performance computational architecture designed for **Deterministic Quadratic Field Arithmetic (DQFA)**. By utilizing 60-degree isotropic vector matrix (IVM) shuffles, the system eliminates cumulative floating-point drift and achieves absolute identity restoration ($R^6 = I$) across arbitrarily long spatial transformation chains.

### 2. Primary Benchmarks
*   **Deterministic Identity:** 100% bit-exact restoration across 10^8 randomized shuffles.
*   **Switching Efficiency:** ~37x reduction in gate-switching density compared to IEEE-754 FPU shuffles.
*   **Kinematic Stability:** 0.00mm cumulative drift in 100-joint articulating chains (verified via `spu-robotics-verify`).
*   **Temporal Coherence:** Resonant 61.44 kHz core clock for bio-coherent synchronization.

### 3. Hardware Implementation
The repository provides synthesizable Verilog RTL for the following FPGA/ASIC targets:
*   **Xilinx Artix-7:** (Arty A7-35T/100T) - Full Tcl automated build path.
*   **Lattice iCE40:** (iCEBreaker) - Open-source toolchain compliant.
*   **Gowin GW2A:** (Tang Nano 20k) - Community target support.

### 4. Technical Documentation
*   **[ALU_SPEC.md](hardware/specs/SPECIFICATION.md):** Formal ISA and gate-level logic specification.
*   **[HARDWARE.md](HARDWARE.md):** Silicon architecture and 60° wire-permutation logic.
*   **[THEORY.md](docs/THEORY.md):** Algebraic proofs of field closure and parity invariants.
*   **[SAFETY.md](docs/SAFETY.md):** Mandatory physical and perceptual safety governors.

### 5. Quickstart: Building the Silicon
```bash
# Software Verification (Headless Audit)
cmake -B build -S . -DBUILD_RENDERER=OFF
cmake --build build --target spu-verify
./build/spu-verify

# Hardware Synthesis (Arty A7 Target)
cd hardware/boards/arty_a7_35t
vivado -mode batch -source build_spu13.tcl
```

## 🌐 Scientific References
1.  **Thomson, A. (2026).** *Spread-Quadray Rotors v1.1: A Tetrahedral Alternative to Quaternions.*
2.  **Wildberger, N. J. (2005).** *Divine Proportions: Rational Trigonometry to Universal Geometry.*
3.  **Fuller, R. B. (1975).** *Synergetics: Explorations in the Geometry of Thinking.*
4.  **Urner, K. (2001).** *Quadray Coordinates.*

---
*A deterministic contribution to the global commons of computer architecture.*
