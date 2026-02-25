# synergetic-renderer (Metal-SQR)

A 3D rendering engine built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**. This project moves away from Cartesian $(x,y,z)$ coordinates to a native 4D tetrahedral coordinate system.

## Core Mandates & Architecture

### 1. The Quadray Coordinate System (4D)
Instead of three orthogonal axes, we use four basis vectors ($Q_1, Q_2, Q_3, Q_4$) pointing from the center of a regular tetrahedron to its vertices.
- **Basis Matrix:**
  - $Q_1 = ( 1,  1,  1)$
  - $Q_2 = ( 1, -1, -1)$
  - $Q_3 = (-1,  1, -1)$
  - $Q_4 = (-1, -1,  1)$
- **Constraint:** Coordinates $(a, b, c, d)$ are traditionally non-negative, representing "energy" flows from the center.

### 2. Spread-Quadray Rotors (SQR)
Based on the February 2026 paper by Andrew Thomson, we implement rotation as a lift into $R^4 	imes Z_2$.
- **Rational Trigonometry:** We avoid transcendental functions (`sin`/`cos`) by using **Spread** ($sin^2$) and **Cross** ($cos^2$).
- **Weierstrass Parametrization:** We pass the $t = 	an(	heta/2)$ parameter to the GPU to calculate rotation coefficients algebraically:
  - $cos(	heta) = \frac{1-t^2}{1+t^2}$
  - $sin(	heta) = \frac{2t}{1+t^2}$
- **Axis Rotation (W-Axis):** Uses circulant-like coefficients $F, G, H$ to rotate the other 3 axes around the fixed Quadray axis.

### 3. The Jitterbug Transformation
The "killer app" for Synergetic rendering. We represent the 12-vertex Vector Equilibrium (VE) and the 6-vertex Octahedron as discrete states in Quadray space.
- **VE State:** Permutations of $(1, 1, 0, 0)$.
- **Octahedron State:** Permutations of $(1, 0, 0, 0)$ (doubled for 12-vertex matching).
- **Interpolation:** By performing `mix(q_ve, q_oct, factor)` directly in Quadray space, we achieve the "twisting" collapse that is geometrically complex in Cartesian math but linear in Synergetics.

## Technical Stack

- **Graphics API:** Apple Metal (Compute-First Pipeline).
- **Language:** C++17 with `metal-cpp` (No Objective-C overhead in the renderer).
- **Tooling:** Python 3 (Dependency-free) for Cartesian-to-Quadray model conversion.
- **Build System:** Makefile (Clang++).

## Key Files

- `src/SynergeticsMath.hpp`: Defines `Quadray` and `SQRotor` structures with SIMD support.
- `src/SynergeticKernel.metal`: The GPU engine performing 4D rotations and ray-casting.
- `src/Renderer.cpp`: Manages Metal buffers (`_veBuffer`, `_octBuffer`) and the compute pipeline.
- `tools/cartesian_to_quadray.py`: The utility for "folding" Cartesian geometry into the tetrahedral grid.
- `src/Models.hpp`: Generated header containing Quadray vertex data for Jitterbug states.

## Current Progress (Feb 24, 2026)
- [x] Established Metal Compute pipeline via `metal-cpp`.
- [x] Implemented 4D Quadray to 3D Cartesian projection.
- [x] Integrated Andrew Thomson's SQR axis-rotation logic.
- [x] **Implemented Janus Polarity ($\pm$ bit):** Resolved sign ambiguity in Rational Trigonometry rotations.
- [x] **Projected Structural Lattice:** Rendered the 24 interconnecting edges of the Jitterbug transformation.
- [x] **Verified Algebraic Determinism:** Successfully completed the "60-degree x 6" test with **zero bit-level drift** using `RationalSurd` math ($\mathbb{Q}[\sqrt{3}]$).
- [x] Verified that Quadray math utilizes the full 4-wide SIMD registers of the GPU.

## Future Research Directions
- **SQR Product (The Janus Product):** Finalize the polynomial multiplication formula for chaining multiple rotors.
- **Fixed-Point Rational Rasterizer:** Move from `float` to integer ratios to achieve **zero-drift** precision.
- **Tetrahedral AABB:** Implement space partitioning using the Octet Truss instead of cubic grids.
- **Vulkan Port:** Move to the desktop PC backend for cross-platform research.
