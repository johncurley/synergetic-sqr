# iCeSugar Phase 1.1: Bring-Up Guide
## SPU-13 Resonant Anchor (v3.3.4)

The iCeSugar Phase 1.1 core is a minimal realization of the SPU-13 manifold, designed to verify **Laminar Silence** and **Geometric Resonance** at the physical boundary.

### 1. Authorization Handshake (The Throttle)
The manifold is safety-gated by the `laminar_en` signal (Pin 10).
*   **Authorization:** Hold Pin 10 **HIGH** (3.3V) to release the Sierpiński Wavefront.
*   **Laminar Halt:** Pull Pin 10 **LOW** (GND) to instantly collapse the manifold heartbeat.

### 2. Manual Bring-Up Procedure
1.  Connect the iCeSugar to your host via USB-C.
2.  Synthesize the bitstream: `cd boards/icesugar && make`.
3.  Flash the core: `make prog`.
4.  **Observe Status LEDs:**
    *   **RED:** System Stall (Hold reset button to verify).
    *   **GREEN:** Manifold Flow (Pulse at 61.44 kHz).
    *   **BLUE:** Counterspace Pulse (Anti-phase to Green).
5.  **Authorize Flow:** Bridge Pin 10 to 3.3V. Observe the Green/Blue LEDs begin their resonant dance.

### 3. Verification
Measure Pins 46 and 47 with an oscilloscope. You should see two 61.44 kHz square waves, exactly 180° out of phase, with minimal switching noise.

---
*Authorized for SPU-13 Silicon Bring-Up.*
