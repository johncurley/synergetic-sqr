# synergetic-sqr
## Deterministic Integer-Based Spatial Transform Engine (ℚ(√3) Fixed-Point)

This repository implements and verifies a deterministic fixed-point transform engine over $\mathbb{Q}(\sqrt{3})$ using integer arithmetic and register permutation.

### Scope
This project demonstrates deterministic fixed-point arithmetic over $\mathbb{Q}(\sqrt{3})$ and verifies closure under defined operations. 

**It does not claim:**
*   Superiority over floating-point GPU pipelines for perception-based tasks.
*   Hardware efficiency improvements (benchmarking pending).
*   Foundational mathematical implications beyond the tested construction.
*   Infinite precision or unbounded execution.

All claims are restricted to reproducible results within the defined 64-bit fixed-point limits.

### v1.8 Milestone: Deterministic Closure Verified
The **SPU-1 (Synergetic Processing Unit)** architecture utilizes **Register Shuffles** and integer-based quadratic field arithmetic to maintain machine-invariant state.

#### Identity Restoration (The Evidence)
```text
--- SPU-1 Deterministic Verification Suite v1.7 ---
Test 1: 100,000,000 consecutive rotations
PASS: No state drift detected within 64-bit bounds.

Test 3: Fixed-Point Scaling Normalization
PASS: Algebraic ratio preserved through 11 normalization cycles.
---------------------------------------
[Identity Verification] Closure verified at Tick: 1000 -> w.a=65536, w.b=0
[Identity Verification] Closure verified at Tick: 5000 -> w.a=65536, w.b=0
```

### Core Representation
Each value in $\mathbb{Q}(\sqrt{3})$ is represented as:
$$x = \frac{a + b\sqrt{3}}{2^{16}}$$
*   **a** and **b** are signed 32-bit integers.
*   All operations are integer-only; no IEEE-754 floating-point operations are used in the transformation logic.

### Instruction Model (SPU-1)
| Instruction | Description | Implementation |
| :--- | :--- | :--- |
| `sadd` | Surd addition | Parallel integer add |
| `smul` | Surd multiplication | Integer multiply-shift |
| `srot60` | 60° rotation | Register permutation |
| `jinv` | Sign inversion | XOR on surd sign-bit |
| `snorm` | Normalization | Fixed-point bounds scaling |

### SQR-ASIC: Hardware Specification
This implementation provides the functional blueprint for a deterministic spatial coprocessor. 
*   **Zero-Gate Rotation:** 60° rotations are implemented as bitfield permutations of Quadray registers.
*   **Algebraic Integrity:** Multiplication maintains closure within the quadratic field extension.

## Documentation
*   **[SPECIFICATION.md](SPECIFICATION.md):** Formal SPU-1 ISA and register layout.
*   **[GLOSSARY.md](GLOSSARY.md):** Technical definitions of algebraic primitives.
*   **[RESEARCH.md](RESEARCH.md):** Data-driven analysis of rotation stability.
*   **[CONTRIBUTING.md](CONTRIBUTING.md):** Architectural integrity guidelines.

## License
Dedicated to the public domain under **CC0 1.0 Universal**. Free for any use without restriction.

---
*A deterministic contribution to the global commons of computer graphics.*
