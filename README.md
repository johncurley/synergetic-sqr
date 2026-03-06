# SPU-13: Isotropic Processing Architecture (v3.1.17)
## Stop Fighting the Float. Achieve Bit-Exact Identity.

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

### 🚀 The Hobbyist's First Light
Most simulation engines lose precision over time. This is called **'Drift.'** SQR (Spread-Quadray Rotor) uses tetrahedral geometry to achieve **Bit-Exact Identity**.
*   **Zero Drift:** 100% data retention over 10^8 rotations.
*   **Zero Pi:** No transcendental functions required for 3D/4D spatial transforms.
*   **Zero Friction:** Native 60-degree coordination for near-reversible switching.

---

### 1. Overview
The SPU-13 (Synergetic Processing Unit) is a deterministic computational architecture designed for **Advanced Fluid Determinism** and high-precision spatial modeling. By utilizing **Isotropic Quadray Coordinates**, the system eliminates the 'Cubic Tax' (coordinate overhead) inherent in standard Cartesian systems.

### 2. Universal Fabric Support (Quickstart Manuals)
The SPU-13 core is board-agnostic. Select your target below to begin synthesis immediately:

| Family | Targeted Board | Toolchain | Quickstart |
| :--- | :--- | :--- | :--- |
| **Xilinx Artix-7** | Arty A7-35T/100T | Vivado (Tcl) | **[Manual](boards/arty_a7_35t/README.md)** |
| **Lattice iCE40** | iCEBreaker | Yosys / nextpnr | **[Manual](boards/icebreaker/README.md)** |
| **Lattice ECP5** | OrangeCrab | Yosys / nextpnr | **[Manual](boards/orangecrab/README.md)** |
| **Gowin GW2A** | Tang Nano 20k | Gowin EDA | **[Manual](boards/tang_nano_20k/README.md)** |
| **Lattice ECP5** | ULX3S | Yosys / nextpnr | **[Manual](boards/ulx3s/README.md)** |
| **Lattice iCE40** | TinyFPGA BX | Yosys / nextpnr | **[Manual](boards/tinyfpga_bx/README.md)** |

### 3. Quickstart: Building the Silicon
```bash
# 1. Software Verification (Headless Audit)
cmake -B build -S . -DBUILD_RENDERER=OFF
cmake --build build --target spu-verify
./build/spu-verify

# 2. Setup the Visual Bridge (Isolated venv)
python3 -m venv venv
source venv/bin/activate
pip3 install pygame pyserial sympy

# 3. Launch the Bloom (Virtual Mode)
python3 sim/python/bloom_view.py --stabilize
```

### 4. Documentation & Spec
*   **[SUNFLOWER_QUICKSTART.md](docs/spec/SUNFLOWER_QUICKSTART.md):** 2-minute bloom demo.
*   **[JARGON_BUSTER.md](docs/spec/JARGON_BUSTER.md):** The bridge to standard engineering terms.
*   **[ALU_SPEC.md](docs/spec/ALU_SPEC.md):** Formal ISA and gate-level logic.
*   **[HARDWARE.md](HARDWARE.md):** 60° wire-permutation and silicon architecture.

---
*A deterministic contribution to the global commons of computer architecture.*
