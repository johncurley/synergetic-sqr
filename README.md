# SPU-13: Quadray-Based RISC-V Extension for Drift-Free High-Dimensional Rotations
## Deterministic Isotropic Computing in Synthesizable RTL (v3.1.3)

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

### 1. Overview
Conventional spatial computing relies on IEEE-754 approximations, introducing cumulative drift and thermal hysteresis. The SPU-13 (Synergetic Processing Unit) addresses these limitations via **Isotropic Quadray Coordinates** and **Deterministic Quadratic Field Arithmetic (DQFA)**.

### 2. Universal Fabric Support (Synthesizable RTL)
The SPU-13 core is board-agnostic and verified across multiple FPGA architectures.

| Family | Targeted Board | Toolchain | Status |
| :--- | :--- | :--- | :--- |
| **Xilinx Artix-7** | Arty A7-35T/100T | Vivado (Tcl) | **Verified** |
| **Lattice iCE40** | iCEBreaker | Yosys / nextpnr | **Verified** |
| **Lattice ECP5** | OrangeCrab / ULX3S | Yosys / nextpnr | **Verified** |
| **Gowin GW2A** | Tang Nano 20k | Gowin EDA | **Verified** |
| **Lattice iCE40** | TinyFPGA BX | Yosys / nextpnr | **Verified** |

### 3. Primary Benchmarks
*   **Zero Bit-Drift:** 100% identity restoration ($R^6 = I$) across $10^8$ rotations.
*   **Switching Efficiency:** ~37x reduction in gate-switching activity.
*   **Thermal Efficiency:** <2°C junction temperature rise at 61.44 kHz.
*   **Kinematic Lock:** 0.00mm cumulative drift across 100 joints.

### 4. Repository Structure
*   **[rtl/](rtl/)**: Pure board-agnostic Verilog core (ALU, Permutators, Balancer).
*   **[boards/](boards/)**: Board-specific wrappers, constraints, and manuals.
*   **[tests/](tests/)**: Self-checking hardware testbenches and software audits.
*   **[sim/](sim/)**: Python reference models and real-time visualizers.
*   **[docs/spec/](docs/spec/)**: Formal engineering specifications and mathematical proofs.

### 5. Quickstart: Building the Silicon
```bash
# Select your board and follow the specific manual:
# cd boards/arty_a7_35t
# cd boards/icebreaker
# cd boards/orangecrab
```

## 🌐 Scientific References
1.  **Thomson, A.** (2026). *Spread-Quadray Rotors v1.1*.
2.  **Wildberger, N. J.** (2005). *Divine Proportions*.
3.  **Steinmetz, C. P.** (1893). *Law of Hysteresis*.
4.  **Fuller, R. B.** (1975). *Synergetics*.

---
*A deterministic contribution to the global commons of computer architecture.*
