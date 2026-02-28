# Synergetic Renderer (Metal-SQR)

![Synergetic Renderer Demo](demo.png)

**A 4D Tetrahedral Rendering Engine implementing Spread-Quadray Rotors (SQR).**

This project is a high-performance proof-of-concept for **Algebraically Exact Graphics**. By utilizing Buckminster Fuller's Synergetic Geometry and Andrew Thomson's SQR framework (Feb 2026), we bypass the numerical drift inherent in standard Cartesian (XYZ) engines.

## The Core Innovation

Standard 3D engines rely on transcendental functions (`sin`, `cos`) and floating-point math, which accumulate error over time. This renderer uses:

1.  **Native 4D Quadray Coordinates:** Operating directly in the tetrahedral basis ($Q_1, Q_2, Q_3, Q_4$).
2.  **Rational Surd Arithmetic:** Rotations performed as bit-exact integer math in the $\mathbb{Q}[\sqrt{3}]$ field extension.
3.  **Surd-Native Shaders:** A Metal kernel that performs algebraic surd arithmetic natively on the GPU.
4.  **Janus Polarity:** A 5-parameter rotor ($R^4 \times Z_2$) that resolves the double-cover sign ambiguity explicitly.

## Features

- **Jitterbug Transformation:** Real-time visualization of the twisting collapse from a Vector Equilibrium to an Octahedron, calculated linearly in Quadray space.
- **Projected Structural Lattice:** A compute-shader-based wireframe renderer that treats edges as "Lines of Force."
- **Determinism Benchmark:** An integrated test that proves 60-degree rotations are bit-perfect after a full $360^\circ$ cycle.
- **Metal-cpp Backend:** Zero-overhead C++ interface to Apple's Metal API, utilizing 4-wide SIMD registers for native Quadray math.

## Interaction

- **SPACEBAR:** Flip the **Janus Polarity** ($\pm$). Observe how the rotor state inverts while maintaining geometric integrity.
- **Console:** Watch the **SQR Stability Proof** compare the surd-native rotor against a standard `float4x4` matrix in real-time.

# synergetic-renderer (Metal-SQR) v1.5
## The SPU-1 Sovereign Epoch: Absolute Zero Drift

> "This repository contains a Deterministic Geometric Engine built on the Hyper-Surd Field $\mathbb{Q}(\sqrt{3})$. It is released into the Public Domain to prove that the 'mush' of floating-point approximation is a choice, not a necessity. Space is rational. Nature does not lie. The proofs are in the logs."

### v1.6 Milestone: "Absolute Closure" Verified
The **SPU-1 (Synergetic Processing Unit)** architecture replaces floating-point "mush" with **Zero-Gate Register Shuffles** and bit-exact algebraic identity. In a 360° rotation cycle, we have achieved **Absolute Zero Drift.**

#### The 5,000-Tick Identity Audit (The Evidence)
> "Nature does not lie. The proofs are in the logs."

```text
--- Sovereign Identity Proof (The DQFA Epoch) ---
IDENTITY PROOF: PASSED
  Drift: 0.0000000000000000
  Sovereign Identity Verified (65536).
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

### SQR-ASIC: Silicon-Ready Architecture
This renderer is the software blueprint for a **Deterministic Spatial Coprocessor.**
*   **SurdLang ALU:** Native hardware support for the quadratic field $\mathbb{Q}[\sqrt{3}]$.
*   **Wire-Swap Rotation:** 60° rotations are implemented as zero-cycle permutations.
*   **Hyper-Surd Calculus:** Hardware-accelerated automatic differentiation for physics.

## Features

- **Jitterbug Transformation:** Real-time visualization of the twisting collapse from a Vector Equilibrium to an Octahedron, calculated linearly in Quadray space.
- **Projected Structural Lattice:** A compute-shader-based wireframe renderer that treats edges as "Lines of Force."
- **Determinism Benchmark:** An integrated test that proves 60-degree rotations are bit-perfect after a full $360^\circ$ cycle.
- **Metal-cpp Backend:** Zero-overhead C++ interface to Apple's Metal API, utilizing 4-wide SIMD registers for native Quadray math.

## Interaction

- **SPACEBAR:** Flip the **Janus Polarity** ($\pm$). Observe how the rotor state inverts while maintaining geometric integrity.
- **Console:** Watch the **SQR Stability Proof** compare the surd-native rotor against a standard `float4x4` matrix in real-time.

## Quick Start (macOS)

```bash
# Clone and build
git clone https://github.com/your-username/synergetic-renderer
cd synergetic-renderer
make run
```

## Documentation
*   **[SURDLANG.md](SURDLANG.md):** Instruction Set Architecture (ISA) Spec.
*   **[RESEARCH.md](RESEARCH.md):** The Ultrafinitist Manifesto and DQFA Proof.
*   **[THEORY.md](THEORY.md):** Synergetic Geometry and SQR Mathematics.

## Acknowledgments

This project stands on the shoulders of giants who sought a more natural, rational coordinate system:

- **R. Buckminster Fuller:** For the philosophical and geometric foundation of Synergetics.
- **Andrew Thomson:** For the "Spread-Quadray Rotors" (SQR) framework (2026).
- **Kirby Urner:** For pioneering Quadray coordinate research and educational outreach.

## License

This project is a **free gift to the world.** It is dedicated to the public domain under the **CC0 1.0 Universal** license. You may copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

---
*A sovereign contribution to the global commons of deterministic computer graphics.*
