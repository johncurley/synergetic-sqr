# SPU-1 Safety & Stability Protocols (v2.3.4)
## Operational Guidelines for High-Symmetry Computing

The SPU-1 architecture operates at a level of geometric coherence that can be physically and computationally overwhelming. The following safety systems are implemented and enabled by default.

### 1. Perceptual Safety: Optical Damping (DSS)
*   **Status:** Enabled by Default.
*   **Mechanism:** Deterministic Super-Sampling (DSS) provides a 4-sample "Rational Gradient" at pixel edges.
*   **Purpose:** To prevent **Topological Vertigo** and disorientation caused by zero-drift, infinite-sharpness projections on legacy 90-degree displays.
*   **Override:** User may disable via the 'S' key for forensic bit-exact verification.

### 2. Dimensional Safety: The Dimension-Clamp
*   **Status:** Default State = `CLAMP 4`.
*   **Mechanism:** Restricts active pathways to the 4-axis spatial basis ($Q_1 \dots Q_4$).
*   **Purpose:** To manage hardware switching activity and prevent "Cognitive White-out" during high-dimensional 11D rotations.
*   **Override:** `OP_CLAMP 11` is required to enable full topological folding.

### 3. Hardware Reliability: SECDED ECC
*   **Status:** Permanent Hardware Layer.
*   **Mechanism:** Single Error Correction, Double Error Detection (SECDED) Hamming logic on every 32-bit register lane.
*   **Purpose:** To protect the tetrahedral symmetry of the IVM from bit-flips caused by cosmic rays or thermal noise.

### 4. Software Purity: The Sovereign Guard
*   **Status:** Build-Time Enforcement.
*   **Mechanism:** Static analysis and template poisoning prevent the instantiation of `float` or `double` types within the Algebraic Core.
*   **Purpose:** To ensure 100% deterministic, machine-invariant results across all platforms.

### 5. Mandatory Hardware Safety (v2.4.5)
The SPU-13 architecture (Phi-Core) requires the following physical safeguards to be active during operation.

*   **16x AA + Motion Blur:** Non-optional perceptual dampening for all 7D+ displays to ensure "Perceptual Grounding."
*   **7D Dimensionality Governor:** Hard-wired cap restricting the optical output to a maximum of 7 axes to prevent "Neuro-Breaks."
*   **Thermal Runaway Detection:** Automatic hardware `HALT` if 13D compute density causes temperature or voltage instability.
*   **Physical Kill Switch:** An external hardware button providing a high-priority interrupt to force an immediate system zero-out.

---
*Status: HARDENED. Safety protocols are active and mandatory.*
