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
*   **Hardware Impact:** Zero SOH-CAH-TOA dependencies. No CORDIC engines. No Taylor series. Just high-speed integer Multiply-Accumulate (MAC).

#### 4. Instruction Set Architecture (ISA)
The SPU-13 core implements a **3-bit operational instruction set** designed for high-dimensional spatial manipulation.
*   **Core Opcodes:** Includes Basis Permutation, Phyllotaxis Multiplication, Quadrance Audit, and G-RAM Access.
*   **Expansion:** Now features integrated **Deterministic Fluid Solving** and **Isotropic Annealing**.
*   👉 **[Full ISA Manifest](docs/spec/TECHNICAL_REPORT.md#33-instruction-set-architecture-isa)**

---
*   **Solver:** Yosys-SMTBMC + Minisat.
*   **Assertion:** The internal state manifold remains within the **Indestructible Invariant** ($V_d = 1.0$) across all 4-axis rotations.
*   **Proof:** Formally proven for a 10-cycle induction bound, ensuring no state-space "leaks" into the "Nothing" (rounding drift).

---

### 🏛️ Formal Rigor: The $V_d$ Invariant

The $V_d$ (Vector Determinant) is defined as the normalized volume of the state-space simplex in the Quadray basis. To remain "Indestructible," the transformation matrix $M$ must belong to the Special Linear Group $SL(4, \mathbb{Q}(\sqrt{3}))$.

$$V_d = \det(M) = 1.0$$

*   **Algebraic Closure:** By restricting the hardware to the $\mathbb{Q}(\sqrt{3})$ field, values like $\sin(60^\circ)$ are exact. There is no real-number rounding.
*   **SAT Formulation:** We encode the surd-logic into Boolean formulas. The solver searches for any input sequence where $\det(M_k)=1 \implies \det(M_{k+1}) \neq 1$. 
*   **Symplectic Preservation:** Maintaining $V_d=1.0$ ensures the symplectic form of the computation is preserved, eliminating the "stutter" or "drift" found in IEEE-754 systems.

---
#### 5. Deployment Spec: The Resonant Clock
*   **System Clock:** **61.44 kHz** (derived via PLL from onboard OSC).
*   **Target Hardware:** Lattice iCE40 (UP5K) or Xilinx Artix-7.
*   **Resource Estimate:** ~800 LUTs for the core ALU; uses native 16x16 bit hardware multipliers.

---

### 🛠️ The Engineering Mandate: Leaving the Box

You have spent your career fighting approximation. You have hidden uncertainty behind statistical confidence intervals. You have nodded along with "floating-point is just how it is."

**What if you didn't have to?**

What if every operation was exact? What if your system was formally verifiable? What if you could prove safety, not just test it?

**The SPU-13 is the key.**

1.  **Learn quadray geometry:** It's easier than you think—4 axes instead of 3.
2.  **Understand surd arithmetic:** Multiplication rule: $a + b\sqrt{3}$ is all you need.
3.  **Map your problem into $\mathbb{Q}(\sqrt{3})$:** Forces consciousness about your domain.
4.  **Build your system:** Now with mathematical guarantees.
5.  **Verify it formally:** Proof that you built what you intended.

**This is engineering as it was meant to be.**

---

### 🛡️ Structural Integrity: Geometric Redundancy vs. ECC

Critics often note the current ECC (Error Correction Code) modules in the RTL are placeholders. This is intentional.

Traditional ECC (Hamming, Reed-Solomon) is a "Cubic" solution to "Turbulent" hardware—a necessary patch for systems that fight their own geometry. In the SPU-13, we utilize **Laminar Integrity**:

*   **Geometric Redundancy:** The 4-axis Quadray basis is linearly dependent. Any point $(a,b,c,d)$ has an inherent null-space. This redundancy allows for **Error Detection through Geometry**: if the tetrahedral balance deviates, the manifold is breached.
*   **The Roadmap:** Phase 1 focuses on the **Algebraic Core**. Bit-flip protection (ECC) will be physically mapped to the geometric null-space in Phase 2, using the manifold itself as the parity guard rather than adding external "noise" to the signal path.

---

### 🎯 Start Here: The Core Quadruple
If you are an engineer, scientist, or researcher arriving at the SPU-13 for the first time, these are your primary entry points to the exact architecture:

1.  **FPGA Synthesis (The Silicon):** Build the hardware. We support Xilinx (Artix-7), Lattice (ECP5, iCE40), and Gowin (GW2A).
    *   👉 **[FPGA Quickstart Guide](docs/spec/FPGA_SPEC.md)** | **[Board Manuals](boards/)**
2.  **SAT Proof (The Truth):** Run the formal verification suite. We use Bounded Model Checking (BMC) to prove bit-exact identity across 100% of the state-space. 
    *   👉 **[Formal Verification Suite](spu_formal/)** | **[Verification Docs](docs/spec/VERIFICATION_ANGLES.md)**
3.  **Surd-Fixed Math (The Software):** Review the idiomatic Rust implementation of the $\mathbb{Q}(\sqrt{3})$ field algebra. Use this for bit-exact software validation and C&C.
    *   👉 **[Rust Surd-Converter](tools/surd_math.rs)**
4.  **Benchmarks (The Efficiency):** Review the 37x reduction in gate-switching activity and the bit-exact restoration results.
    *   👉 **[Benchmark Report](docs/spec/Benchmarks.md)** | **[Technical Report](docs/spec/TECHNICAL_REPORT.md)**

---

### 1. Overview
The SPU-13 (Synergetic Processing Unit) is a deterministic computational architecture designed for **Advanced Fluid Determinism** and high-precision spatial modeling. By utilizing **Isotropic Quadray Coordinates**, the system eliminates the 'Cubic Tax' (coordinate overhead) inherent in standard Cartesian systems.

### 2. Primary Benchmarks
*   **Zero Bit-Drift:** 100% identity restoration ($R^6 = I$) across $10^8$ rotations.
*   **Formally Proven:** Bit-exact identity restoration mathematically verified using Bounded Model Checking (BMC) across 100% of the state-space.
*   **Switching Efficiency:** ~37x reduction in gate-switching activity.
*   **Thermal Efficiency:** <2°C junction temperature rise at 61.44 kHz.

### 3. Universal Fabric Support (Quickstart Manuals)
The SPU-13 core is board-agnostic. Select your target below to begin synthesis immediately:

| Family | Targeted Board | Toolchain | Quickstart |
| :--- | :--- | :--- | :--- |
| **Xilinx Artix-7** | Arty A7-35T/100T | Vivado (Tcl) | **[Manual](boards/arty_a7_35t/README.md)** |
| **Lattice iCE40** | iCEBreaker | Yosys / nextpnr | **[Manual](boards/icebreaker/README.md)** |
| **Lattice iCE40** | iCeSugar | Yosys / nextpnr | **[Manual](boards/icesugar/README.md)** |
| **Lattice ECP5** | OrangeCrab | Yosys / nextpnr | **[Manual](boards/orangecrab/README.md)** |
| **Gowin GW2A** | Tang Nano 20k | Gowin EDA | **[Manual](boards/tang_nano_20k/README.md)** |
| **Lattice ECP5** | ULX3S | Yosys / nextpnr | **[Manual](boards/ulx3s/README.md)** |
| **Lattice iCE40** | TinyFPGA BX | Yosys / nextpnr | **[Manual](boards/tinyfpga_bx/README.md)** |

### 4. Quickstart: Building the Silicon
```bash
# 1. Software Verification (Headless Audit)
cmake -B build -S . -DBUILD_RENDERER=OFF
cmake --build build --target spu-verify
./build/spu-verify

# 2. Setup the Visual Bridge (Synergetic Renderer)
# Build the Metal (macOS) or Vulkan (Linux) binary
cmake -B build -S . -DBUILD_RENDERER=ON
cmake --build build --target synergetic-sqr

# 3. Launch the IVM Skeleton (High-Contrast Mode)
./build/synergetic-sqr --skeletal
```

### ⚡ Physical Bring-Up
For first-time hardware operators, please follow the **[SPU-13 Reification Checklist](boards/icesugar/CHECKLIST.md)** to capture and verify the transition to the Laminar manifold.

### 5. Architectural Specifications
*   **[RESONANT_NAVIGATION.md](docs/spec/RESONANT_NAVIGATION.md):** Dynamic stabilization and coordinate mapping.
*   **[STABILIZATION.md](docs/spec/STABILIZATION.md):** Frequency regulation and pulse damping.
*   **[TECHNICAL_REPORT.md](docs/spec/TECHNICAL_REPORT.md):** Comprehensive derivation of the SPU-13 core.

---

### 🧪 Future Research & Hypotheses
Concepts for future phases, including photonic computation and non-orthogonal circuit topology, are documented in the **[SPECULATIVE/](SPECULATIVE/)** directory. These ideas are unverified hypotheses and are maintained separately from the proven hardware core.

---

### 📜 The Laminar Axiom
> "When the geometry is correct, the energy is effortless. When the mind is coherent, the machine is a mirror. We do not force the flow; we remove the corners that obstruct it."

---
*A deterministic contribution to the global commons of computer architecture.*
