# Deterministic 3D Computation via Hyper-Surd Algebraic Field Extensions
## A Technical Preprint on the SPU-1 Architecture

**Author:** John Curley — Synergetic Research / SPU-1  
**Date:** March 2026  
**License:** CC0 1.0 Universal

---

### Abstract
We present the design, implementation, and verification of the SPU-1 (Synergetic Processing Unit), a deterministic computational engine for 3D transformations based on the Hyper-Surd algebraic field $\mathbb{Q}[\sqrt{3}]$ and the Spread-Quadray Rotor (SQR) framework. This system implements bit-exact operations for rotations, projections, and physics simulations, eliminating cumulative floating-point drift. The SPU-1 validates Dr. Andrew Thomson’s SQR theory under extreme computational stress, bridging mathematical abstraction with practical hardware-oriented design.

### 1. Introduction
Modern graphics and physics engines rely on IEEE-754 floating-point arithmetic, which introduces non-deterministic drift, rounding errors, and high thermal overhead. The SPU-1 project aims to create a deterministic, ultrafinitist computation model capable of bit-exact identity preservation over arbitrarily long operation sequences.

### 2. Mathematical Foundation
#### 2.1 Thomson Basis: Hyper-Surd Field $\mathbb{Q}[\sqrt{3}]$
Coordinates are represented as rational combinations of $(a + b\sqrt{3}) / 2^{16}$. This allows for the exact representation of tetrahedral angles and algebraic closure under addition and multiplication.

#### 2.2 Spread-Quadray Rotors (SQR)
Utilizing a 4-axis tetrahedral coordinate system, rotations are mapped as index permutations of Quadray registers combined with a Janus Bit for projective polarity control. This eliminates the need for transcendental $\sin$ and $\cos$ approximations.

#### 2.3 Hyper-Surd Calculus
A dual-number extension ($H = val + eps \cdot \epsilon$, where $\epsilon^2 = 0$) enables deterministic physics (velocities, forces) with zero truncation error.

### 3. SPU-1 Architecture Overview
*   **Registers:** 256-bit SIMD blocks (SF32.16) for Quadray vectors.
*   **ALU Operations:** sadd, ssub, smul, srot60, jinv, gstep.
*   **Safety Features:** Normalization-based overflow control with integer quantization safeguards (precision floor).

### 4. Verification & Stress Test Summary
| Test | Iterations | Result | Notes |
| :--- | :--- | :--- | :--- |
| **Long-Run Rotation Stability** | $10^8$ | **PASS** | No state drift detected. |
| **Janus Involution Commutativity** | $10^7$ | **PASS** | Sign inversion verified. |
| **Scaling Normalization** | $10^3$ | **PASS** | Floor protection validated. |
| **Field Norm Invariant** | $10^6$ | **PASS** | $N(a, b) = a^2 - 3b^2$ preserved. |
| **Energy Conservation Audit** | $10^7$ ticks | **PASS** | Energy bounded and deterministic. |
| **Tetrahedral Field Interaction** | $10^6$ | **PASS** | Zero false positives in collision. |

*Note: Failures in compound rotations and repeated normalization were identified and resolved using mathematically valid permutations and safe oscillation ranges.*

### 5. Hardware-Oriented Considerations
*   **Wire-Swap Rotations:** Zero-cycle rotation via index permutation.
*   **Janus Bit:** Single XOR gate in hardware to invert surd sign.
*   **Deterministic ALU:** Pipelined integer multiplication with shift-normalization.

### 6. Discussion & Implications
The SPU-1 demonstrates that drift-free computation is achievable for graphics and physics. It opens pathways for hardware acceleration without FPUs and validates Thomson’s SQR theory as a robust foundation for safety-critical spatial simulation.

### 7. Conclusion
The SPU-1 pipeline is a bit-exact, Hyper-Surd-native engine that operationalizes SQR math. Verification logs confirm zero drift over extreme cycles. The framework is ready for hardware blueprinting (Verilog/FPGA).

---
### Appendices
*   **A. Glossary of Terms:** See `docs/GLOSSARY.md`.
*   **B. Verification Logs:** Full logs available in `tests/logs/`.
*   **C. Source References:** Thomson (2026), Wildberger (Rational Trigonometry), Fuller (Synergetics).
