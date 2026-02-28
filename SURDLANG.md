# SurdLang Specification (v1.7)
## Deterministic Quadratic Field Arithmetic (DQFA)

SurdLang is the instruction set architecture for the **SPU-1** (Synergetic Processing Unit). It enables machine-invariant spatial computation over the quadratic field $\mathbb{Q}[\sqrt{3}]$ using fixed-point integer arithmetic.

### 1. Core Scalar: `SurdFixed64` ($SF_{32.16}$)
The fundamental unit of the system.
*   **Representation:** $(a + b\sqrt{3}) / 2^{16}$
*   **Storage:** 64-bit per element (dual 32-bit integers: `a` and `b`).
*   **ALU Operation (SMUL):** 
    - $(a_1 + b_1\sqrt{3})(a_2 + b_2\sqrt{3}) = (a_1a_2 + 3b_1b_2) + (a_1b_2 + b_1a_2)\sqrt{3}$
    - **Intermediate:** 64-bit integer accumulator.
    - **Normalization:** Arithmetic right-shift by 16 bits.

### 2. Core Types
| Type | Description | Structure |
| :--- | :--- | :--- |
| `SurdFixed64` | Base Algebraic Scalar | `int32_t a, b` |
| `DualSurd` | Hyper-Surd (for derivatives) | `SurdFixed64 val, eps` |
| `Quadray4` | 4D Tetrahedral Coordinate | `SurdFixed64 q[4]` (256-bit SIMD) |
| `SurdRotorFixed` | Unit Rotation Rotor | `SurdFixed64 w, x` |

### 3. Intrinsics (Instruction Set)
The SPU-1 implements the following operations in hardware:

*   **`SADD`**: Surd Addition. Bit-exact parallel integer addition.
*   **`SMUL`**: Surd Multiplication. Integer multiplication with shift-normalization.
*   **`SPERM`**: Register Shuffle. 60° rotation implemented as a zero-cycle routing operation.
*   **`JINV`**: Sign Inversion. XOR on the surd component's sign bit.
*   **`SNORM`**: Normalization. Arithmetic right-shift to preserve fixed-point bounds.

### 4. Deterministic Identity
By replacing transcendental functions with **Register Shuffles** and the **Rational Oscillator**, the SPU-1 achieves bit-exact identity closure. Under repeated transformation, the identity state $w=65536, x=0$ is preserved with zero drift.
