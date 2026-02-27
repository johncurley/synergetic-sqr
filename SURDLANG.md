# SurdLang Specification (v1.4)
## Deterministic Quadratic Field Arithmetic (DQFA)

SurdLang is the instruction set for the **SQR-ASIC** (Synergetic Quadray Rotor ASIC). It enables bit-exact spatial computation over the quadratic field $\mathbb{Q}[\sqrt{3}]$ using fixed-point integer arithmetic.

### 1. The Core Scalar: `SurdFixed64`
The fundamental unit of the system.
*   **Representation:** $(a + b\sqrt{3}) / 2^{32}$
*   **Storage:** 128-bit (dual 64-bit integers: `a` and `b`).
*   **ALU Operation (SMUL):** 
    - $(a_1 + b_1\sqrt{3})(a_2 + b_2\sqrt{3}) = (a_1a_2 + 3b_1b_2) + (a_1b_2 + b_1a_2)\sqrt{3}$
    - **Intermediate:** 128-bit integer accumulator.
    - **Normalization:** Right-shift by 32 bits.

### 2. Core Types
| Type | Description | Structure |
| :--- | :--- | :--- |
| `SurdFixed64` | Base Algebraic Scalar | `int64_t a, b` |
| `DualSurd` | Hyper-Surd (for derivatives) | `SurdFixed64 val, eps` |
| `SurdVector3` | 3D Vector in surd space | `SurdFixed64 x, y, z` |
| `SurdMatrix3x3` | Tetrahedral Transformation | `SurdFixed64 m[9]` |
| `SurdRotorFixed` | Unit Rotation Rotor | `SurdFixed64 w, x` |

### 3. Intrinsics (Instruction Set)
The SQR-ASIC implements the following operations in hardware:

*   `sadd(a, b)`: Surd Addition (Bit-exact parallel integer add).
*   `smul(a, b)`: Surd Multiplication (Integer multiplication with shift-normalization).
*   `srot60(v)`: **Wire-Swap Rotation.** A 60° rotation in the Quadray basis is a zero-cycle routing operation (permutation of coordinates).
*   `jinv(v)`: **Janus Bit.** Toggles the polarity of the surd component (Conjugation).
*   `gstep(u, v)`: **Leibniz Product.** $(u \cdot v, u \cdot v' + u' \cdot v)$. Propagates exact derivatives for physics.

### 4. The Stability Guarantee: "Absolute Zero" Drift
By replacing the floating-point `sin()` and `cos()` with **Rational Rotors** and the **Rational Oscillator**, the drift error for a 360° rotation cycle is **Exactly 0.00000000**. 

Computational Henosis is achieved when the software logic and the physical hardware lattice are in perfect alignment.
