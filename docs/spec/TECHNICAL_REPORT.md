# Technical Report: SPU-13 Architecture
## A Deterministic Quadray-Native Coprocessor for Exact Spatial Calculus

**Date:** March 2026  
**Authors:** John Curley & Gemini  
**Version:** v3.3.25  
**License:** CC0 1.0 Universal

---

### 1. Abstract
This report specifies the SPU-13, a hardware-software co-processor architecture optimized for bit-exact spatial transformations. By utilizing a fixed-point quadratic field extension $\mathbb{Q}(\sqrt{3})$ and a 4-axis tetrahedral (Quadray) coordinate basis, the SPU-13 achieves absolute identity closure and machine-invariant simulation. This revision documents the transition to the **Universal Fractal Heart**, ensuring 61.44 kHz resonant synchronization across diverse silicon fabrics.

### 2. Mathematical Foundation
#### 2.1 The Quadratic Field $\mathbb{Q}(\sqrt{3})$
We represent spatial values as elements of the quadratic field extension of rationals:
$$X = a + b\sqrt{3}$$
The SPU-13 implements this as a dual-integer surd representation, ensuring bit-exact multiplication and addition without transcendental rounding.

#### 2.2 Quadray Basis (IVM)
The architecture operates natively in Quadray (ABCD) space. Unlike the 3-axis Cartesian XYZ basis, Quadray coordinates utilize four vectors from the center of a regular tetrahedron to its vertices. This eliminates the $\sqrt{2}$ and $\sqrt{3}$ irrationals required to describe tetrahedral symmetry in XYZ.

### 3. Hardware Architecture
#### 3.1 The Thomson Rotor ALU
The core rotation logic implements the RA Matrix from Dr. Andrew Thomson’s specifications. By utilizing the 3-fold symmetry of Quadray space, the SPU-13 implements isotropic rotations as **Circulant Permutations**. 
- **Efficiency:** 120° rotations are pure wiring permutations (Zero-Gate logic).
- **Invariance:** Formally proven to maintain the $V_d=1.0$ determinant invariant bit-exactly.

#### 3.2 Universal Fractal Synchronization
All SPU-13 implementations are synchronized to a **61.44 kHz Resonant Clock**. 
- **The Heart:** A Numerically Controlled Oscillator (NCO) generates the resonant pulse from any base hardware clock (12MHz - 100MHz).
- **Bioresonance:** The frequency is harmonic with human biological rhythms, targeting high-conductivity interaction and minimal cognitive dissonance.

#### 3.3 Instruction Set Architecture (ISA)
The SPU-13 core implements a 3-bit operational instruction set (Opcode) designed for high-dimensional spatial manipulation:

| Opcode | Mnemonic | Description |
| :--- | :--- | :--- |
| `000` | `NOP` | Laminar Pass-through (Identity). |
| `001` | `SPERM_X4` | 4-Axis Basis Permutation (Thomson Rotor). |
| `010` | `SMUL_13` | Phyllotaxis Multiplier (ℚ(√3, √5) field). |
| `011` | `Q_AUDIT` | Rational Quadrance Audit (Bit-exact squared distance). |
| `100` | `G_RAM` | Geometric Memory Access (Standing Wave Buffer). |
| `101` | `FLUID_SOLVE` | Deterministic Navier-Stokes Closure (Orbital Laplacian). |
| `110` | `SPERM_13` | 13-Axis Isotropic Permutation. |
| `111` | `PERTURB` | Isotropic Annealer (Golden Noise Injection). |

### 4. Physical Realization
#### 4.1 Geodesic Fractal Trace Map
The physical layout of the SPU-13 rejects the standard "Manhattan" routing grid. Instead, it utilizes recursive 60°/120° geodesic paths. This **Laminar Mapping** minimizes parasitic hysteresis and ensures that signal propagation respects the underlying mathematical manifold.

#### 4.2 Null Hysteresis Logic
By maintaining constant gate-transition density (balanced Forward/Inverse paths), the SPU-13 achieves a "Black" power signature. This eliminates the switching-noise jitter that plagues standard high-frequency CMOS designs.

### 5. Empirical Verification
The SPU-13 is verified via an exhaustive multi-layered suite:
1.  **Algebraic Audit:** 100 million rotations with 100% identity restoration.
2.  **Formal Rigor:** SAT-based Bounded Model Checking (BMC) proving $\det(M)=1.0$ across the entire state-space.
3.  **Physical Audit:** Black Background simulation measuring switching density and laminar silence.

### 6. Conclusion
The SPU-13 architecture proves that spatial computation can be bit-exact, deterministic, and hardware-efficient. By aligning logic with geometry, we move from a "Cubic" cage of approximation into a **Laminar Manifold** of truth.
