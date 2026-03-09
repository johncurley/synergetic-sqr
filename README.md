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

#### 2. The Number System: $\mathbb{Q}(\sqrt{3})$ Surd Fixed-Point
The SPU-13 does not use IEEE-754 Floating Point. It uses a **Dual-Integer Surd Representation**.
*   **Storage:** Each value is a pair of signed integers $(I, S)$ representing $I + S\sqrt{3}$.
*   **Multiplication Rule:** $(I_1 + S_1\sqrt{3}) \times (I_2 + S_2\sqrt{3}) = (I_1I_2 + 3S_1S_2) + (I_1S_2 + S_1I_2)\sqrt{3}$
*   **The Result:** **Zero Rounding Error.** The product is bit-exact and algebraically closed.

#### 3. Rational Trigonometry (Universal Geometry)
We replace transcendental $\sin/\cos$ with **Spread ($s$)** and **Quadrance ($Q$)** (as defined by Norman Wildberger).
*   **Quadrance:** $Q = d^2$ (Distance squared). Pure integer calculation.
*   **Spread:** $s = \sin^2(\theta)$. Exact rational values.
*   **Tetrahedral Symmetry:** For 60° angles, $s = 0.75$ (Exactly representable as $3/4$).
*   👉 **[Universal Verification Plan](docs/spec/VERIFICATION_PLAN.md)**

---

### 🛡️ Universal Verification Stack (The Four Tiers)

To satisfy the **Zero-Tolerance Verification Mandate**, the SPU-13 utilizes a tiered audit strategy. Every bit must be accounted for before the manifold is authorized for commit.

#### 1. Prerequisites
Install the formal, mathematical, Python, and FPGA synthesis toolchains:
```bash
# Formal Logic & Synthesis
brew install sby yosys yices2 z3

# FPGA Synthesis (iCE40)
brew install --HEAD icestorm yosys nextpnr-ice40

# Python Visualizer
pip3 install -r requirements.txt

# Render Support (Metal/Vulkan)
brew install sdl3
```

#### 2. Tier 1: The Commit Guard (Local)
Automate verification before every commit using the provided Git hook. 
```bash
# Install the hook
ln -sf $(pwd)/tools/hooks/pre-commit .git/hooks/pre-commit
```

#### 3. Tier 2 & 3: Algebraic & Chaos Audits (CTest)
Run the 14-suite mathematical audit to verify bit-exact identity closure and stress-test the surd field under chaos.
```bash
cmake -B build -S . -DBUILD_RENDERER=OFF
cd build && ctest -j8 --output-on-failure
```

#### 4. Tier 4: Formal Sign-Off (SymbiYosys)
Prove the $V_d=1.0$ algebraic invariant mathematically for all possible states using SMT-based k-induction.
```bash
cd spu_formal && sby -f vd_determinant.sby
```

---

### 🚀 2026 Development Roadmap: Universal Parity

The SPU-13 is committed to **Zero-Tax Cross-Platform Parity**. The following milestones define the path forward for the manifold:

#### 1. Emulation & Rendering
*   **Metal (macOS):** [STABLE] Full bit-exact compute pipeline with DSS.
*   **Vulkan (Linux/Windows):** [BETA] Migrating `SDL_gpu` structural shell to full SPIR-V compute parity.
*   **Python:** [STABLE] Integrating multi-lane mapping from `spu13_emulator.py` into the real-time Bloom UI. Launch via: `python3 sim/python/bloom_view.py --demo`

#### 2. Synthesis & Silicon
*   **iCE40 (iCESugar):** [PRIMARY] Maintaining golden reification standards. Use `TOP=icesugar_full_manifold make` for Phase 1.2.
*   **Artix-7 / ECP5 / GW2A:** [PARITY] Standardizing all board `Makefiles` to use the configurable `TOP` variable for 100% logic alignment across family boundaries.
*   **Formal Proofs:** Extending `sby` coverage to the **Laminar Power Dispatch** and **ECC Recovery** sub-modules.

---

### ⚡ Physical Bring-Up (iCESugar Phase 1.0 Bootstrap)
For rapid reification on the iCESugar board, utilize the minimal bootstrap targets:
```bash
cd boards/icesugar
# Build 'Hello World' (ABCD LED Rotation)
make TOP=blinky_symmetry 
# Build Minimal Kernel (Rational Quadray)
make TOP=spu13_minimal_core
```
For first-time hardware operators, please follow the **[SPU-13 Reification Checklist](boards/icesugar/CHECKLIST.md)** to capture and verify the transition to the Laminar manifold.

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
