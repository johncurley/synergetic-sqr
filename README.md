# Synergetic Renderer (Metal-SQR)

**A 4D Tetrahedral Rendering Engine implementing Spread-Quadray Rotors (SQR).**

This project is a high-performance proof-of-concept for **Algebraically Exact Graphics**. By utilizing Buckminster Fuller's Synergetic Geometry and Andrew Thomson's SQR framework (Feb 2026), we bypass the numerical drift inherent in standard Cartesian (XYZ) engines.

## The Core Innovation

Standard 3D engines rely on transcendental functions (`sin`, `cos`) and floating-point math, which accumulate error over time. This renderer uses:

1.  **Native 4D Quadray Coordinates:** Operating directly in the tetrahedral basis ($Q_1, Q_2, Q_3, Q_4$).
2.  **Rational Trigonometry:** Rotations performed using **Spread** and **Cross** measures (polynomial math).
3.  **Algebraic Determinism:** Utilizing the $\mathbb{Q}[\sqrt{3}]$ field extension to achieve bit-exact rotations with **zero numerical drift**.
4.  **Janus Polarity:** A 5-parameter rotor ($R^4 	imes Z_2$) that resolves the double-cover sign ambiguity without quaternions.

## Features

- **Jitterbug Transformation:** Real-time visualization of the twisting collapse from a Vector Equilibrium to an Octahedron, calculated linearly in Quadray space.
- **Projected Structural Lattice:** A compute-shader-based wireframe renderer that treats edges as "Lines of Force."
- **Determinism Benchmark:** An integrated test that proves 60-degree rotations are bit-perfect after a full $360^\circ$ cycle.
- **Metal-cpp Backend:** Zero-overhead C++ interface to Apple's Metal API, utilizing 4-wide SIMD registers for native Quadray math.

## Quick Start (macOS)

```bash
# Clone and build
git clone https://github.com/your-username/synergetic-renderer
cd synergetic-renderer
make run
```

## Proof of Determinism

At startup, the engine runs a benchmark performing six $60^\circ$ rotations using the `RationalSurd` class. 
- **Result:** `SUCCESS: Result is BIT-EXACT to original.`
- **Significance:** Unlike `float4x4` or Quaternions, this system returns to the *exact same bit-pattern* regardless of hardware or duration.

## Acknowledgments

- **R. Buckminster Fuller:** For the philosophical and geometric foundation of Synergetics.
- **Andrew Thomson:** For the "Spread-Quadray Rotors" framework (2026).
- **Kirby Urner:** For pioneering Quadray coordinate research.

---
*Created as an exploration into the future of deterministic, nature-friendly computer graphics.*
