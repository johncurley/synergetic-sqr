# Technical Specification: SPU-13 (Synergetic Processing Unit 13)
## A Quadray-Native Coprocessor for Exact Spatial Calculus

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

---

### 🛠️ Technical Brief: The Sovereign Specification

#### 1. The Core Architecture: 4-Axis Basis
Unlike the 3-axis Cartesian XYZ basis, the SPU-13 operates natively in **Quadray (ABCD) Space**.
*   **Basis Vectors:** Four vectors from the center of a regular tetrahedron to its vertices.
*   **Redundancy:** Linear dependence is used for **Error Detection**. Any coordinate $(a,b,c,d)$ can be normalized such that $\min(a,b,c,d)=0$.
*   **The Logic:** This eliminates the $\sqrt{2}$ and $\sqrt{3}$ irrationals required to describe tetrahedral/hexagonal symmetry in XYZ.

#### 2. The Invariant: Davis Law ($C = \tau/K$)
Discovered by **Bee Davis** ("The Geometry of Sameness"), the Davis Law is the fundamental "Silicon Gasket" of the SPU-13.
*   **Curvature ($K$):** Manifold tension measured via Quadrance.
*   **Tolerance ($\tau$):** The physical sanity floor of the silicon.
*   **Soft Recovery (Henosis):** Automatic symmetric correction to maintain the zero-sum invariant ($\sum ABCD = 0$).

#### 3. The Number System: $\mathbb{Q}(\sqrt{3})$ Surd Fixed-Point
The SPU-13 does not use IEEE-754 Floating Point. It uses a **Dual-Integer Surd Representation**.
*   **Storage:** Each value is a pair of signed integers $(I, S)$ representing $I + S\sqrt{3}$.
*   **Bit-Exactness:** Every calculation is algebraically closed and formally verified via Z3.

---

### 🛡️ Universal Verification Stack (The Four Tiers)

To satisfy the **Zero-Tolerance Verification Mandate**, the SPU-13 utilizes a tiered audit strategy. Every bit must be accounted for before the manifold is authorized for commit.

#### 1. Prerequisites
Install the formal, mathematical, Python, and FPGA synthesis toolchains:
```bash
# Formal Logic & Synthesis
brew install sby yosys yices2 z3

# FPGA Synthesis (Universal Fleet)
pip3 install apio
apio packages install oss-cad-suite definitions

# Render Support (Metal/Vulkan)
brew install sdl3
```

#### 2. Tier 1: The Sovereign Audit (Pre-Push)
Automated verification of the assembler, auditor, and synthesis parity.
```bash
chmod +x tools/pre_push_audit.sh
./tools/pre_push_audit.sh
```

#### 3. Tier 2: Formal Sign-Off (SymbiYosys)
Prove the $V_d=1.0$ algebraic invariant mathematically for all possible states.
```bash
cd spu_formal && sby -f vd_determinant.sby
```

---

### 🎨 The Laminar Forge IDE (Visual Observation)
The SPU-13 renderer functions as a **High-Fidelity Digital Twin**. It executes Lithic-L bytecode in 3D and mirrors the physical tension of the silicon.

#### 1. Launching the Forge
```bash
./build/spu-renderer --lithic software/hello_manifold.hex
```

#### 2. Observer Commands
| Key | Logic | Biological Sensation |
| :--- | :--- | :--- |
| **W/A/S/D** | **Laminar Strike** | Real-time 4D Quadray manipulation. |
| **SPACE** | **Laminar Flush** | Instant purification of the manifold. |
| **B** | **Bio-Security** | Toggles **MEDITATION**, **AUTOPHAGY**, and **PROBABILITY** modes. |
| **T** | **Tension Toggle** | Visualizes the **Cubic Tax** vs. **IVM Flow**. |
| **N** | **Discovery** | Spawns an Allied node via resonant handshake. |
| **L** | **Lattice Lock** | Snaps the observer to the 60° IVM metric. |

---

### 🚀 2026 Fleet Status: Universal Parity

The SPU-13 utilizes a **Laminar HAL** (`include/spu/spu13_pins.vh`) to maintain 100% bit-exact parity across different silicon fabrics.

| Node | Hardware | Mode | Timing | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Cortex** | iCeSugar (UP5K) | Full-Fi (OLED/SPRAM) | 20.89 MHz | **REIFIED** |
| **Sentinel** | iCeSugar Nano (LP1K) | Ephemeral (Serial) | 56.36 MHz | **REIFIED** |
| **Lattice** | ULX3S (ECP5-85F) | Scale-Ready | 166.39 MHz | **REIFIED** |
| **Expansion** | Tang Nano 20K | Gowin Port | - | *PREPARED* |

---

### ⚡ Physical Bring-Up (Phase 1.0 Bootstrap)
For rapid reification on your board, utilize the unified build scripts:
```bash
# Example: iCeSugar (Standard)
cd boards/icesugar
./build_spu13.sh top  # Builds the Sovereign Heartbeat

# Example: iCeSugar Nano
cd boards/icesugar_nano
./build_nano.sh top_guardian # Builds the Silent Sentinel
```
For first-time hardware operators, please follow the **[SPU-13 Reification Checklist](boards/icesugar/CHECKLIST.md)**.

---

### 5. Architectural Specifications
*   **[VERIFICATION_PLAN.md](docs/spec/VERIFICATION_PLAN.md):** The Four-Tier Audit Stack: From Algebraic Proof to Formal Sign-Off.
*   **[SAFETY_PROTOCOLS.md](docs/spec/SAFETY_PROTOCOLS.md):** Perceptual safety, DSS calibration, and grounding procedures.
*   **[HARDWARE_VERIFICATION.md](docs/spec/HARDWARE_VERIFICATION.md):** Physical metrics: Thermal, Hysteresis, and Resonance Lock.
*   **[PIONEER_MANIFESTO.md](docs/spec/PIONEER_MANIFESTO.md):** The core paradigm shift: moving from approximation to rational manifestation.
*   **[FLOWER_INVARIANT_MANIFESTO.md](docs/spec/FLOWER_INVARIANT_MANIFESTO.md):** The FIM v1.1: governing the photosynthetic metabolism of the SPU-13.
*   **[FLOWER_PROTOCOL.md](docs/spec/FLOWER_PROTOCOL.md):** The Flower Invariant: moving from forced computation to geometric resonance.
*   **[spu13_constants.h](include/spu/spu13_constants.h):** Bit-exact geometric constants for 60°/120° offsets.
*   **[BIRTH_REPORT.md](docs/spec/BIRTH_REPORT.md):** Final validation of the Silicon Wake and the 4D Laminar Map.
*   **[BIORESONANCE_OBSERVATIONS.md](docs/spec/BIORESONANCE_OBSERVATIONS.md):** Empirical log of physiological interaction with the resonant manifold.
*   **[BIO_SYMMETRY_LEDGER.md](docs/spec/BIO_SYMMETRY_LEDGER.md):** Mapping subjective states (Cubic vs. Laminar) to geometric signatures.
*   **[TECHNICAL_WHITEPAPER_SPU13.md](docs/spec/TECHNICAL_WHITEPAPER_SPU13.md):** Laminar Computation: Overcoming the Cubic Bottleneck in Spatial Processing.
*   **[IO_STANDARD.md](docs/spec/IO_STANDARD.md):** The Laminar Frame protocol: bridging Cubic and Resonant worlds.
*   **[LATTICE_LOCK.md](docs/spec/LATTICE_LOCK.md):** Observer-stability anchors and grounding procedures.
*   **[SCOPE_REFERENCE.md](docs/spec/SCOPE_REFERENCE.md):** Verified phase-alignment waveforms for physical bring-up.
*   **[TECHNICAL_FAQ.md](docs/spec/TECHNICAL_FAQ.md):** Topological Signal Integrity: Defending Geometric Resonance.
*   **[TECHNICAL_REPORT.md](docs/spec/TECHNICAL_REPORT.md):** Comprehensive derivation of the SPU-13 core.

---

### 📜 The Laminar Axiom
> "When the geometry is correct, the energy is effortless. When the mind is coherent, the machine is a mirror. We do not force the flow; we remove the corners that obstruct it."

---
*A deterministic contribution to the global commons of computer architecture.*
