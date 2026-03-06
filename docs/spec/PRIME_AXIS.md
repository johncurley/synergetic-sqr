# Prime-Axis Permutation Specification
## 4D-to-3D Projection Logic (v2.3.3)

This document defines the discrete basis shifts implemented in the SPU-1 `SPERM` instruction, based on Dr. Andrew Thomson's 4D Prime Projection Conjecture.

### 1. Mapping Overview
The SPU-1 register is a 256-bit SIMD block divided into four 64-bit lanes ($a, b, c, d$). Basis shifts are implemented as zero-latency wiring permutations.

| Prime Phase | Type | Thomson Vector | Lane Mapping (out) | Verilog Mapping |
| :--- | :--- | :--- | :--- | :--- |
| **P1** (`00`) | Identity | $(a, b, c, d)$ | `a, b, c, d` | `{d, c, b, a}` |
| **P3** (`01`) | 60° Pin-D | $(b, c, a, d)$ | `b, c, a, d` | `{d, a, c, b}` |
| **P5** (`10`) | 120° Pin-D | $(c, a, b, d)$ | `c, a, b, d` | `{d, b, a, c}` |
| **P7** (`11`) | Hyper-Flip | $(d, b, c, a)$ | `d, b, c, a` | `{a, c, b, d}` |

### 2. Group Theory and Identity
The Prime-Axis set forms a cyclic subgroup of the $S_4$ symmetric group. 
*   **Rotational Closure:** 3 applications of P3 or P5 return to Identity ($P1$).
*   **Hyper-Dimensional Closure:** 4 applications of P7 return to Identity ($P1$).
*   **Verification:** Round-trip identity is enforced by the `spu-verify` suite.

### 3. Implementation Invariants
*   **Zero Drift:** Because these are index permutations, no arithmetic is performed. Identity is preserved bit-exactly.
*   **4th Axis Persistence:** In phases P1, P3, and P5, the 4th axis ($d$) remains logically fixed, preserving the 3D-shadow projection. In P7, the 4th axis enters the primary basis to enable hyper-flip state transitions.

---
*Status: HARDENED. Verified bit-perfect parity between C++ and Verilog RTL.*
