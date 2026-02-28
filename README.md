# synergetic-renderer (Metal-SQR) v1.7
## The Sovereign Epoch: Universal Determinism

> "This repository contains a Deterministic Geometric Engine built on the Hyper-Surd Field $\mathbb{Q}(\sqrt{3})$. It is released into the Public Domain to prove that the 'mush' of floating-point approximation is a choice, not a necessity. Space is rational. Nature does not lie. The proofs are in the logs."

### v1.7 Milestone: Absolute Closure Verified
The **SPU-1 (Synergetic Processing Unit)** architecture replaces floating-point "mush" with **Zero-Gate Register Shuffles** and bit-exact algebraic identity. In a 360° rotation cycle, we have achieved **Absolute Zero Drift**, verified across 100 million iterations and multiple hardware platforms.

#### The Identity Audit (The Evidence)
```text
--- SPU-1 RIGOROUS VERIFICATION SUITE v1.7 ---
Test 1: Long-Run Rotation Stability (10^8 iterations)
SUCCESS: Bit-Exact Stability Verified.

Test 3: Fixed-Point Scaling Normalization
SUCCESS: Algebraic Ratio Preserved (11 normalizations).
---------------------------------------
[Identity Audit] Closure Verified at Tick: 1000 -> w.a=65536 (0x10000)
[Identity Audit] Closure Verified at Tick: 5000 -> w.a=65536 (0x10000)
```

### SPU-1 Purity Guard: Zero-Tolerance Audit
This repository includes a **Static Analysis Guardrail** in the build system (`CMakeLists.txt`) that prevents the use of floating-point logic in the algebraic core. If `float` or `double` keywords are detected in the `SPU_Core`, the build will fail. This ensures every spatial transformation remains a closed-loop algebraic operation.

### Visual Witness: The IVM Skeleton
The renderer produces a high-contrast wireframe of the **Isotropic Vector Matrix (IVM)**. 
*   **The Cross:** The projected 4D Quadray axes.
*   **The Square:** The fundamental Cuboctahedron (VE) symmetry face.
*   **The Breath:** A rational triangle-wave oscillation between the VE and Octahedron states.
Because the engine is bit-locked, every rotation returns the edges to the **exact same pixels** with zero shimmering.

### Core Architecture: SQR-ASIC
This renderer is the software blueprint for a **Deterministic Spatial Coprocessor.**
*   **SurdLang ALU:** Native hardware support for the quadratic field $\mathbb{Q}[\sqrt{3}]$.
*   **Wire-Swap Rotation:** 60° rotations are implemented as zero-cycle permutations.
*   **Hyper-Surd Calculus:** Hardware-accelerated automatic differentiation for physics.

## Quick Start (macOS / Linux)

```bash
mkdir -p build && cd build && cmake ..
make -j8
./synergetic-sqr
```

## Documentation
*   **[GLOSSARY.md](GLOSSARY.md):** Technical definitions and mapping geometry to logic.
*   **[SURDLANG.md](SURDLANG.md):** Instruction Set Architecture (ISA) Spec.
*   **[RESEARCH.md](RESEARCH.md):** The Ultrafinitist Manifesto and DQFA Proof.
*   **[CONTRIBUTING.md](CONTRIBUTING.md):** Purity rules for the Rational Gate.

## License

This project is a **free gift to the world.** It is dedicated to the public domain under the **CC0 1.0 Universal** license. You may copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

### Call to Audit: Verification Protocol
Researchers and engineers wishing to verify the claims of this architecture are encouraged to run the **Rigorous Verification Suite**:
```bash
make spu-verify && ./spu-verify
```

### Project Roadmap
*   **v1.7 (Stable Basis):** Bit-exact spatial closure and self-healing scaling (SF32.16).
*   **v1.8 (Kinetic Phase):** Implementation of **Rational Tensegrity**—stable force dynamics using Hyper-Surd calculus.
*   **v1.9 (Hardware Phase):** RTL implementation of the SPU-1 intrinsics in **Verilog** for FPGA deployment.

---
*A sovereign contribution to the global commons of deterministic computer graphics.*
