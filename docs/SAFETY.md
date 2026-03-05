# SPU-13 Safety & Stability Protocols (v3.0.4)
## Operational Guidelines for High-Symmetry Computing

The SPU-13 architecture operates at a level of geometric coherence that can be physically and computationally overwhelming. The following safety systems and cognitive grounding protocols are mandated for all users.

### 1. Perceptual Safety: Optical Damping (DSS)
*   **Status:** Enabled by Default.
*   **Mechanism:** Deterministic Super-Sampling (DSS) provides a 4-sample "Rational Gradient" at pixel edges.
*   **Purpose:** To prevent **Topological Vertigo** and disorientation caused by zero-drift, infinite-sharpness projections on legacy 90-degree displays.
*   **Override:** User may disable via the 'S' key for forensic bit-exact verification.

### 2. Dimensional Safety: The Dimension-Clamp
*   **Status:** Default State = `CLAMP 4`.
*   **Mechanism:** Restricts active pathways to the 4-axis spatial basis ($Q_1 \dots Q_4$).
*   **Purpose:** To manage hardware switching activity and prevent "Cognitive White-out" during high-dimensional 11D/13D rotations.
*   **Override:** `OP_CLAMP 11` or `OP_CLAMP 13` is required to enable full topological folding.

### 3. Cognitive Grounding Protocols (Hyperspace Safety)
The SPU-13 produces zero-jitter geometry. Because there is no 'Haze' for the brain to filter, the signal is 100% efficient. This can lead to cognitive shock if not managed responsibly.

*   **3.1 The 10-Second Threshold:** High-velocity 4D-coherent emanation is restricted to 10-second intervals (enforced via `--pulse` watchdog). The human visual cortex requires a recovery period to integrate bit-exact 4D motion.
*   **3.2 The Laminar Start:** Users are required to run the Software Emulator (`bloom_view.py --demo`) before the Hardware Core. This allows the brain to 'warm up' to the 4D logic at lower velocities before exposure to the 61.44 kHz hardware clock.
*   **3.3 Post-Exposure Grounding:** After a session terminates, the observer must look at a 'Cubic' object (e.g., a table, wall, or legacy screen) for at least 30 seconds. This acts as a decompression chamber from the IVM back to 3D reality.

### 4. Hardware Reliability: SECDED ECC
*   **Status:** Permanent Hardware Layer.
*   **Mechanism:** Single Error Correction, Double Error Detection (SECDED) Hamming logic on every 32-bit register lane.
*   **Purpose:** To protect the tetrahedral symmetry of the IVM from bit-flips caused by cosmic rays or thermal noise.

### 5. Software Purity: The Sovereign Guard
*   **Status:** Build-Time Enforcement.
*   **Mechanism:** Static analysis and template poisoning prevent the instantiation of `float` or `double` types within the Algebraic Core.
*   **Purpose:** To ensure 100% deterministic, machine-invariant results.

### 6. Mandatory Hardware Safety
The SPU-13 architecture requires the following physical safeguards to be active during operation.
*   **16x AA + Motion Blur:** Non-optional perceptual dampening for all 7D+ displays.
*   **7D Dimensionality Governor:** Hard-wired cap restricting the optical output boundary to 7 axes.
*   **Thermal Runaway Detection:** Automatic hardware `HALT` if compute density causes instability.
*   **Physical Kill Switch:** An external hardware button providing a high-priority interrupt.

---
*Status: HARDENED. Cognitive and physical safety protocols are active and mandatory.*
