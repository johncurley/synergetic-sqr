# SPU-1 Technical Glossary (v1.7)
## Definition of Discrete Algebraic Primitives

This document defines the technical implementation of terms used in the Synergetic-SQR architecture.

| Specification | Technical Definition | Hardware Implementation |
| :--- | :--- | :--- |
| **Fixed-Point Scaling** | Normalization routine | Arithmetic right-shift (`>> 1`) on surd coefficients to preserve fixed-point bounds. Includes a precision floor (threshold: 256) to prevent state collapse during repeated scaling cycles. |
| **Register Permutation** | Index-based rotation | Cyclic shift of coordinate indices in the 4D Quadray register; requires zero arithmetic gates. |
| **Bit-Exact Identity** | Deterministic Closure | Machine-invariant output achieved by utilizing integer arithmetic in the $\mathbb{Q}(\sqrt{3})$ field extension. |
| **SurdFixed64** | Quadratic Field Element | A fixed-point representation of the algebraic field $\mathbb{Q}(\sqrt{3})$, stored as two 32-bit integers (a, b) with implicit denominator. |
| **DualSurd** | Hyper-dual Number | An extension of SurdFixed64 with an infinitesimal component for derivative propagation; used for algebraic automatic differentiation. |
| **Janus Bit** | Sign-Inversion Bit | A single bit controlling the sign inversion of the surd component. Implemented as a bitwise XOR on the surd’s sign bit. |
| **Identity Test** | Runtime Verification | A verification procedure where repeated rotor application must return to a bit-exact starting state. |
| **IVM Basis** | Tetrahedral Mapping | A 4-axis coordinate system stored in a memory-aligned 256-bit SIMD block (`SPU_Vector256`). |
| **Rational Oscillator** | Piecewise-Linear Driver | A deterministic triangle-wave driver derived from the frame tick count for scale oscillation. |
| **Vector Equilibrium** | Zero-Point State | The cuboctahedron baseline where all vectors are of equal magnitude and energy. |
| **Integer Displacement** | Quadrance Tension | Tension defined as the exact integer distance squared between lattice nodes. |
| **Equilibrium Verification** | Force Balance Check | A node-level audit where the sum of all Quadray tension vectors must project to zero. |

## SPU-1 Instruction Set Architecture (ISA)
*   `_spu_rotate_60`: Index permutation of the Quadray register wires.
*   `_spu_surd_mul`: Integer multiply-shift with shift-and-add constant optimization.
*   `_spu_normalize`: Leading-zero count detection and right-shift overflow handling.
*   `_spu_add_q4`: SIMD parallel integer vector addition.
