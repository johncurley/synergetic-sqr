# SPU-13 ASIC Migration Roadmap
## Transitioning to Open-Source Silicon (v2.9.0)

This document outlines the strategy for migrating the SPU-13 architecture from FPGA prototyping to physical ASIC fabrication using the Sky130 PDK.

### 1. Phase 1: Arty A7 Final Prototyping
Before tape-out, the RTL must be verified for long-run thermal and timing stability on the Artix-7 target.
*   **Metric:** $10^7$ continuous ticks with zero bit-error.
*   **Goal:** Confirm the 832-bit bus doesn't cause excessive voltage droop during Prime-Axis shuffles.

### 2. Phase 2: Sky130 PDK Porting
Utilizing the **OpenLane** flow to translate SPU-13 Verilog into GDSII (the physical layout format).
*   **Standard Cell Mapping:** Replacing FPGA LUTs with native CMOS logic gates.
*   **Harmonic Floorplanning:** Implementing radial placement constraints to minimize interconnect length between the 12-neighbor clusters.

### 3. Phase 3: Google MPW Shuttle Application
Submission of the SPU-13 design to the **Efabless/Google Open MPW Program**.
*   **The Target:** A physical batch of 130nm silicon chips.
*   **Sovereignty:** The first hardware implementation of bit-perfect isotropic logic in permanent silicon.

### 4. Phase 4: Tetrahedral Final Form
Long-term research into non-standard die packaging.
*   **Die Stacking:** Vertical integration of SPU clusters to achieve 3D tetrahedral signal propagation.
*   **Fractal Clocking:** Implementing a central "H-Tree" clock that pulses outward symmetrically, ensuring the "Rational Pulse" reaches all gates simultaneously.

---
*Status: FOUNDRY PREP. Preparing for tape-out.*
