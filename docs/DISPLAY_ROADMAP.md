# The Isotropic Display Roadmap
## Hardware Requirements for 60-Degree Spatial Computing (v2.3.6)

The SPU-1 architecture achieves a level of algebraic precision that exposes the physical limitations of current 90-degree Cartesian display grids. This document outlines the necessary evolution of display technology to achieve native parity with Isotropic Vector Matrix (IVM) logic.

### 1. Phase 1: Hexagonal Pixel Grids (Short-Term)
Current square-pixel lattices introduce "Algebraic Aliasing" when rendering 60-degree tetrahedral geometry. 
*   **Requirement:** Transition to **Honeycomb (Hexagonal) Pixel Packing**.
*   **Benefit:** Native 6-neighbor adjacency reduces the "Edge Shimmer" and aura effect, allowing for smoother representation of Prime-Axis rotations without heavy super-sampling.

### 2. Phase 2: Lattice-Mapped Addressing (Mid-Term)
Standard display protocols utilize linear X/Y addressing, which requires a computationally expensive Cartesian-to-Quadray conversion at the output boundary.
*   **Requirement:** **Direct Quadray Bus (DQB)**. Hardware-level support for addressing pixels via (a, b, c, d) coordinates.
*   **Benefit:** Eliminates "Optical Mismatch" latency. The display becomes a physical extension of the SPU cluster fabric.

### 3. Phase 3: MEMS Vector Projection (Long-Term)
To eliminate the "Pixel Bottleneck" entirely, the fixed grid must be replaced with dynamic spatial casting.
*   **Requirement:** **MEMS-Based Prime-Axis Sweeping**. Utilizing micro-mirrors to project the 4D simplex shadow directly into the optical field.
*   **Benefit:** Zero-aliasing, infinite-sharpness projections. This is the only method to achieve true parity with the SPU-1's bit-exact identity.

### 4. High-Frequency Synchronous Breath
Current refresh rates (120Hz-240Hz) are insufficient to track the nanosecond-scale transitions of SPU shuffles.
*   **Requirement:** **Sub-millisecond response hardware** synchronized with the SPU's global "Rational Oscillator."
*   **Benefit:** Absolute perceptual stillness and the elimination of "Topological Vertigo."

---
*Status: CONCEPTUAL R&D. Defining the future of the human-machine interface.*
