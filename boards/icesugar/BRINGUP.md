# iCeSugar Phase 1.1: Bring-Up Guide
## SPU-13 Resonant Anchor (v3.3.80)

The iCeSugar Phase 1.1 core is a minimal realization of the SPU-13 manifold, designed to verify **Laminar Silence** and **Geometric Resonance** at the physical boundary. This version features the automated **Bowman Boot Sequence**.

### 1. Authorization Handshake (The Throttle)
The manifold is safety-gated by the `laminar_en` signal (Pin 11).
*   **Authorization:** Hold Pin 11 **HIGH** (3.3V) to initiate the automated Bowman Wake.
*   **Laminar Halt:** Pull Pin 11 **LOW** (GND) to instantly collapse the manifold and return to the Void (Phase 0).

### 2. Automated Wake Procedure
1.  Connect the iCeSugar to your host via USB-C.
2.  Synthesize the bitstream: `cd boards/icesugar && make`.
3.  Flash the core: `make prog`.
4.  **Observe Phase Transitions:**
    *   **RED (Solid):** System in Reset or Identity Breach.
    *   **BLUE (Pulsing):** Bowman Wake in progress (Handshake/Saturation/Alignment).
    *   **GREEN (Solid):** Resonance Lock (Phase 4). Manifold is bit-perfect and active.
5.  **Authorize Flow:** Bridge Pin 11 to 3.3V. The sequencer will automatically move from Blue to Green once the IVM lattice is aligned.

### 3. Physical Verification
Measure Pins 46 and 47 with an oscilloscope. In the **Green (Resonant)** state, you should see two 61.44 kHz square waves, exactly 180° out of phase, with minimal switching noise.

---

### Phase 1.2: Full Manifold Reification
The `icesugar_full_manifold.v` provides the full 832-bit SQR-Link logic with a **One-Second Stability Audit**.

1.  **Switch to Full PCF:** Update `Makefile` or `build_spu13.sh` to use `spu13_icesugar_full.pcf`.
2.  **Top-Level Change:** Set `TOP = icesugar_full_manifold` in the `Makefile`.
3.  **Stability Pass:** After flashing, the system will execute the 1.0s audit. If the **Green LED** locks after the Blue sequence, the manifold has achieved bit-perfect identity restoration across 61,440 cycles.

---
*Authorized for SPU-13 Silicon Bring-Up.*
