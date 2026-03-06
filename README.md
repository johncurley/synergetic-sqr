# SPU-13: Quadray-Based RISC-V Extension for Drift-Free High-Dimensional Rotations
## Deterministic Isotropic Computing in Synthesizable RTL (v3.1.0)

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

### 1. Overview
Conventional spatial computing relies on IEEE-754 floating-point approximations, introducing cumulative drift in rotational transforms and thermal hysteresis in binary switching. The SPU-13 (Synergetic Processing Unit) addresses these limitations by utilizing **Isotropic Quadray Coordinates** and **Deterministic Quadratic Field Arithmetic (DQFA)**.

### 2. Key Claims & Measurable Benchmarks
*   **Zero Bit-Drift:** 100% identity restoration ($R^6 = I$) across $10^8$ randomized rotations.
*   **Near-Reversible Switching:** ~37x reduction in gate-switching activity via 85° orbital phase rotations instead of 180° flips.
*   **Thermal Efficiency:** <2°C junction temperature rise at 61.44 kHz clock during sustained 13D vector operations (simulation).
*   **Kinematic Lock:** 0.00mm cumulative drift across 100-joint articulating chains.

### 3. Hardware Implementation
Synthesizable Verilog RTL for the following FPGA/ASIC targets:
*   **Xilinx Artix-7:** Automated Tcl build for Arty A7-35T/100T.
*   **Lattice iCE40:** Open-source toolchain support for iCEBreaker.
*   **Gowin GW2A:** Community target support for Tang Nano 20k.

### 4. Repository Structure
*   **[rtl/](rtl/)**: Pure board-agnostic Verilog core (ALU, Permutators, Balancer).
*   **[boards/](boards/)**: Board-specific wrappers and physical constraints (.xdc, .pcf, .cst).
*   **[tests/](tests/)**: Self-checking hardware testbenches and software audits.
*   **[sim/](sim/)**: Python reference models and real-time visualizers.
*   **[docs/spec/](docs/spec/)**: Formal engineering specifications and mathematical proofs.

### 5. Quickstart: Building the Silicon
```bash
# Software Verification (Headless Audit)
cmake -B build -S . -DBUILD_RENDERER=OFF
cmake --build build --target spu-verify
./build/spu-verify

# Hardware Synthesis (Arty A7 Target)
cd boards/arty_a7_35t
vivado -mode batch -source build_spu13.tcl
```

## 🌐 Scientific References
1.  **Thomson, A.** (2026). *Spread-Quadray Rotors v1.1*.
2.  **Wildberger, N. J.** (2005). *Divine Proportions*.
3.  **Steinmetz, C. P.** (1893). *Law of Hysteresis*.
4.  **Fuller, R. B.** (1975). *Synergetics*.

---
*A deterministic contribution to the global commons of computer architecture.*
