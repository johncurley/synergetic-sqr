# SPU-1 Technical Glossary (v1.7)
## Mapping Geometry to Logic

This document provides boring, technical definitions for the conceptual terms used in the Synergetic-SQR architecture.

| Concept | Technical Definition | Implementation |
| :--- | :--- | :--- |
| **Self-Healing Scale** | Fixed-point normalization | Arithmetic right-shift (`>> 1`) on surd coefficients when approaching 32-bit boundaries. |
| **Zero-Gate Rotation** | Register Shuffle / Permutation | Cyclic shift of coordinate indices in the 4D Quadray register; requires no arithmetic gates. |
| **Sovereign Determinism** | Bit-Exact Identity | Machine-invariant output achieved by purging all IEEE-754 floating-point units from the logic path. |
| **DQFA** | Quadratic Field Arithmetic | Fixed-point integer pairs representing $(a + b\sqrt{3}) / 2^{16}$ in the $\mathbb{Q}[\sqrt{3}]$ field. |
| **Janus Bit** | Sign-Bit XOR | A single-bit toggle that negates the surd component (`b`) of a field element. |
| **Hyper-Surd Calculus** | Dual-Number Automatic Differentiation | A dual-lane arithmetic path $(val, \epsilon \cdot deriv)$ where $\epsilon^2 = 0$. |
| **IVM Skeleton** | Tetrahedral Basis Mapping | A 4-axis coordinate system stored in a 256-bit SIMD block (`SPU_Vector256`). |
| **Rational Oscillator** | Integer Triangle Wave | A piecewise-linear scale driver derived from the frame tick count. |
| **Computational Henosis** | Logic-Hardware Parity | The state where high-level algebraic operations map 1:1 to low-level hardware intrinsics. |

## SPU-1 Instruction Set Summary
*   `_spu_rotate_60`: Index permutation of the Quadray register.
*   `_spu_surd_mul`: Integer multiply-shift with shift-and-add `*3` optimization.
*   `_spu_normalize`: Leading-zero count detection and right-shift.
*   `_spu_add_q4`: SIMD parallel integer addition.
