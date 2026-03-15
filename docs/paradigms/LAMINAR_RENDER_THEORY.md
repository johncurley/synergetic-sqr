# Laminar Rendering Theory: Beyond the Cartesian Pixel (v1.0)
## Objective: High-Fidelity Visual Resonance via Symmetry-Native Rasterization.

Standard graphics programming is a series of "Cubic Taxes" paid to simulate reality. The SPU-13 removes these taxes by rendering natively in the 60-degree manifold.

### 1. Resonant Texturing
Standard UV mapping forces hexagonal or organic textures into 90-degree boxes, causing distortion.
- **IVM Addressing:** Textures are indexed via $\{a,b,c\}$ coordinates.
- **Sampling:** Uses the **Rational Multiplier** for bit-exact interpolation.
- **Benefit:** Textures remain perfectly symmetrical regardless of viewing angle.

### 2. Physically Based Resonance (Laminar PBR)
We replace standard PBR parameters with **Manifold Invariants**:
- **Coherency (Metallic):** How well the surface preserves the 60-degree phase of incoming light.
- **Dissonance (Roughness):** The degree of random axis-shifting (entropy) at the surface level.
- **Refraction:** A logic-shift in the Quadray vectors as they pass through a medium boundary.

### 3. Lighting & Occlusion
- **Falloff:** Calculated as `Intensity * RATIONAL_LUT[Quadrance]`.
- **Shadows:** Handled via **Lattice Intersection**. If a vector strike is blocked by another node's integer coordinate, the path is dark. 
- **Anti-Aliasing:** Not required. Since pixels are snapped to the IVM lattice, "edges" are mathematically exact.

### 4. Operational Modes: The Sovereign Bridge

To transition from legacy hardware to the Symmetry Engine, the SPU-13 operates in two primary modes:

-   **Native (Hex Grid): The Sovereign Truth**
    In this mode, the hardware assumes a physical 60-degree pixel arrangement (Triad or Hexagonal). The $\{a,b,c\}$ coordinates map 1:1 to the physical display resonators. There is zero "math" required for rasterization—the vector *is* the pixel path. This is the zero-entropy state of visual stillness.

-   **Bresenham (Cubic Trash): The Legacy Bridge**
    Required for standard 90-degree LCD/OLED screens. Standard Bresenham is "Cubic Trash" because it forces a 60-degree truth into a 90-degree lie, creating "jags" and temporal flicker. The SPU-13 "heals" this bridge using the **Laminar Ephemeral Sealant (v1.5)**: a rational parabolic energy projection that nudges sub-pixels to simulate the 60-degree path on a square grid.

---
*Status: REIFIED. The light is coherent. The bridge is healed.*
