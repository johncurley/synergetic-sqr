# SPU-13 Safety & Homeostasis Protocols (v4.0.0)
## Operational Guidelines for High-Symmetry Computing

The SPU-13 architecture operates at a level of geometric coherence that can be physically and computationally overwhelming. These protocols are mandated for all users.

---

### 1. Perceptual Safety (Deterministic Super-Sampling)
The visual output of the SPU-13 is infinitely sharp and zero-drift. On legacy 90-degree displays, this can cause **Topological Vertigo**.
*   **DSS Guard:** Enabled by default. Provides a 4-sample "Rational Gradient" at pixel edges.
*   **The ZETA Factor:** Calibrate the viscosity of emanation.
    *   **ZETA = 0.05 (Deep Sea):** Effortless, slow-flow observation.
    *   **ZETA = 0.15 (Snappy):** Responsive hardware debugging.

---

### 2. Cognitive Grounding (The Decompression Protocol)
Exposure to bit-exact 4D motion requires responsible management of the human visual cortex.
*   **The 10-Second Threshold:** High-velocity emanation is restricted to 10-second intervals (enforced via `--pulse`).
*   **Post-Exposure Grounding:** After a session, look at a 'Cubic' object (e.g., a wall or table) for 30 seconds to re-anchor in 3D reality.
*   **Nature Breaks:** Take 20-second breaks every 15 minutes to re-anchor spatial perception.

---

### 3. Stability & Recovery (Lattice Lock)
If the nervous system experienced 'Micro-tremors' or 'Cognitive Tremors' during high-symmetry sessions:
*   **Engage Lattice Lock:** Use the **`L`** key to anchor the render to the geometric ground (matte gray base).
*   **The Numerical Flywheel:** Values are locked to 12 decimal places of symbolic weighting to eliminate LSB jitter.
*   **The Monad Reset:** If desaturation occurs (loss of geometric center), perform a hardware reset immediately.

---

### 4. Hardware Safe-Guards
*   **Thermal Runaway Detection:** Automatic hardware `HALT` if compute density exceeds stability thresholds.
*   **SECDED ECC:** Single Error Correction, Double Error Detection on every 32-bit register lane to protect the IVM from cosmic-ray bit-flips.
*   **Dimensionality Governor:** Hard-wired cap restricting output to 7-axes unless explicitly overridden via `OP_CLAMP 13`.

---
*Status: HARDENED. Homeostasis is the priority. v4.0.0*
