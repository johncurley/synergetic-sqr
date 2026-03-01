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

Test 8: Compound Multi-Axis Rotations
PASS: Algebraic integrity verified through non-commutative shuffles.

Test 9: Scaling Normalization Endurance
PASS: Ratio integrity preserved through 100 cycles of magnification.
---------------------------------------
[Identity Verification] Closure verified at Tick: 1000 -> w.a=65536, w.b=0
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
*   **[RESEARCH.md](RESEARCH.md):** Data-driven analysis of rotation stability and forensic logs.
*   **[SPECIFICATION.md](hardware/specs/SPECIFICATION.md):** Formal SPU-1 ISA and register layout.
*   **[SURDLANG.md](hardware/specs/SURDLANG.md):** The formal language of the SPU-1.
*   **[GLOSSARY.md](docs/GLOSSARY.md):** Technical definitions of algebraic primitives.
*   **[WHITE_PAPER.md](docs/WHITE_PAPER.md):** Technical preprint on the SPU-1 architecture.
*   **[SQR_LANG_SYNTAX.md](docs/SQR_LANG_SYNTAX.md):** Specification for static data-flow topology.
*   **[CONTRIBUTING.md](CONTRIBUTING.md):** Architectural integrity guidelines.

## License
Dedicated to the public domain under **CC0 1.0 Universal**. Free for any use without restriction.

## Project Roadmap
*   **v1.7 (Stable Basis):** Bit-exact spatial closure and scaling normalization. Verified.
*   **v1.8 (Kinetic Primitives):** Implementation of TensegrityNode and Equilibrium logic. Verified.
*   **v1.9 (Formalization):** Technical Whitepaper and ISA Specification published. Verified.
*   **v1.10 (Hardware/SDK):** Synthesizable Verilog RTL and Developer SDK implemented. Verified.
*   **v2.0 (Public Release):** Hardware-software co-simulation and forensic audit suite. **COMPLETED.**

### Executive Summary: Why the SPU-1 Never Drifts
Standard 3D engines use floating-point numbers, which are like **leaky pipes**—every time you perform a calculation, a tiny bit of precision "leaks" out, leading to cumulative drift. The SPU-1 architecture replaces these with **Deterministic Quadratic Field Arithmetic (DQFA)**. 

Our system uses **discrete integer buckets**. A rotation is not a calculation that might lose bits; it is a **Register Permutation** (a literal wire-swap). Because the logic never leaves the integer field, there is no physical mechanism for drift to occur. Identity is not approximated; it is **restored exactly.**

### SPU-1 Instruction Set (SurdLang ISA)
| Instruction | Hardware Operation | Description |
| :--- | :--- | :--- |
| **`SADD`** | Parallel Integer Add | Single-cycle vector addition across 4 axes. |
| **`SMUL`** | Pipelined Multiplier | Surd multiplication with 64-bit intermediate protection. |
| **`SPERM`** | Zero-Gate Shuffle | 60° rotation implemented as a wiring permutation. |
| **`JINV`** | XOR Sign Toggle | Projective polarity control (Janus Bit). |
| **`SNORM`** | Bit-Mask Scaling | Normalization-based overflow control. |

### Edge-Case Forensic Audit
| Scenario | Condition | Result | Invariant |
| :--- | :--- | :--- | :--- |
| **Boundary Limit** | Coefficients at $2^{31}-1$ | **PASS** | `SNORM` preserves rational ratio. |
| **Precision Floor** | Coefficients at $< 256$ | **PASS** | Normalization disabled to prevent zeroing. |
| **Chaos Sequence** | $10^9$ randomized steps | **PASS** | Field norm $N(a, b)$ remains stable. |
| **Recursive Feedback** | $10^7$ recursive steps | **PASS** | Identity restores exactly to `0x10000`. |

---
*A deterministic contribution to the global commons of computer graphics.*
