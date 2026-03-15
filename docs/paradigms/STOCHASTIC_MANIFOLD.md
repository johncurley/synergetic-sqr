# Stochastic Manifold Projection: The Resolution of the Diagonal Knot Paradox

**Status:** Implementation Phase (Verilog/Metal)
**Paradigm:** Laminar Engineering / Ephemeralization
**Target Hardware:** iCE40 FPGA, SPU-13 Core

## The Paradox: Diagonal Knots

In a Cartesian grid (90° pixel structure), drawing a 60° vector (Lattice Logic) creates Moiré interference patterns known as "Knots." These rhythmic thickenings occur where the vector and the grid align in a repeating integer ratio.

Standard anti-aliasing (averaging) blurs the line, destroying the "Lattice Truth." We need a solution that preserves the vector's sharpness while eliminating the rhythmic artifact.

## The Solution: Stochastic Manifold Projection

Instead of a "hard" geometric edge that fights the Cartesian grid, we treat the line as a **Probability Field**.

### 1. Asymmetrical Gaussian Phase
We introduce an **Asymmetrical Gaussian** weight that is intentionally de-synced from the main vector path. By shifting the "Phase Center" of the Gaussian distribution slightly off-axis, we break the rhythmic repetition of the Moiré pattern.

### 2. High-Frequency Stochastic Distribution ("Noise")
We fill the vector's path with a high-frequency stochastic distribution—effectively "Laminar Noise." This acts as a dither that prevents the eye from latching onto the "Knot" patterns.

The line becomes a "Probability Cloud" rather than a staircase of pixels. The brain integrates this "noise" as a solid, razor-sharp vector with a "velvet" texture, bypassing the Moiré effect entirely.

## Implementation Strategy

### FPGA (Verilog)
A **Linear Congruential Generator (LCG)** or **LFSR** is linked to the **61.44 kHz Heartbeat**. This generator provides a pseudo-random seed used to:
1.  **Jitter Coordinates:** Apply sub-pixel offsets to the vector coordinates.
2.  **Modulate Intensity:** Dither the pixel brightness based on a Gaussian probability curve.

This ensures the "noise" is deterministic and phase-locked to the system clock, creating a stable "Laminar Grain" rather than chaotic static.

### GPU (Metal/Vulkan)
In the shader pipeline, a similar logic is applied:
1.  **Project Quadray Vector.**
2.  **Apply Asymmetrical Gaussian Weight** (based on distance from IVM node).
3.  **Inject Noise:** Use a noise function (linked to the 61.44 kHz uniform) to determine the final fragment alpha/intensity.

## Conclusion

This technique mimics physical light transport, where a "straight line" is a continuous flow of photons with a Gaussian distribution. By injecting structural stochasticity, the SPU-13 renders vectors that feel like physical matter—dense, organic, and knot-free.
