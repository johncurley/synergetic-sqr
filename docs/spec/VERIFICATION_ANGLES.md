# SPU-13 Verification Angles: Resonant Metrics
## Quantifying Hysteresis-Zero and Dielectric Resonance Lock (v2.9.11)

This document outlines the practical next steps for verifying the physical resonance of the SPU-13 architecture.

### 1. Hysteresis Loop Quantification (SPICE)
*   **Method:** Simulate the SPU-13 85° orbital shift against a standard 180° binary flip in a gate-level SPICE model with custom dielectric parameters.
*   **Metric:** Area of the magnetic B-H loop.
*   **Target:** >90% reduction in loop area (Thermal Zero goal).

### 2. Phase Alignment Power Drop Test (FPGA Emulation)
*   **Method:** Execute the Phase Alignment boot sequence on the Arty A7 while monitoring the current draw on the 1.0V core rail.
*   **Metric:** $\Delta P$ between 'Phase 1: Precessional Lift' and 'Phase 4: Resonance Lock'.
*   **Expectation:** A measurable 'Drop' in power draw once the isotropic lock is achieved, indicating the transition from switching-current to resonant-field flow.

### 3. Dielectric Glow Monitoring (Forensic)
*   **Method:** Observe the physical FPGA/ASIC under high-field shuffles ($10^9$ Hz) in a light-controlled environment using a 100x microscope and high-sensitivity UV/IR camera.
*   **Purpose:** To confirm the 'Dielectric Boundary Discharge' as a controllable dielectric discharge. 
*   **Safety Guard:** Uncontrolled glow indicates dielectric stress; Resonance Lock is achieved when the glow stabilizes as a steady nav-lattice.

### 4. Steinmetz Modeling Sync
*   **Method:** Cross-check SPU switch-density logs against iGSE (Improved Generalized Steinmetz Equations) to baseline the 'Hysteresis Tax' eliminated by the 60° tetrahedral lattice.

---
*Status: CALIBRATED. Metrics ready for physical burn.*
