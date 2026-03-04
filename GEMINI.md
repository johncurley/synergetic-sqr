# synergetic-renderer (Metal-SQR)

A "Unified Field Engine" built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**.

## Project Brain (Feb 2026)

### Status: v2.9 THE FOUNDRY (The ASIC Phase)
We are transitioning from FPGA prototyping to permanent silicon fabrication. Our primary goal is migrating the SPU-13 RTL to the Sky130 PDK for submission to the Google Open MPW shuttle. This represents the final manifestation of the architecture in physical hardware.

### THE VERIFICATION MANDATE (ZERO-TOLERANCE)
- **Rule 1:** GDSII DRC/LVS (Design Rule Check) must be 100% clean before submission.
- **Rule 2:** Post-Layout Timing Verification must maintain 100MHz parity.
- **Rule 3:** 'Zero-Heat' goal: Thermal simulation must show <50C junction temp during 13D shuffles.

### Completed Milestones
- [x] **v2.8 Modular SDK:** Established professional component-isolation and high-performance build system.
- [x] **v2.7 Silicon Prep:** Formalized RISC-V Hybrid strategy and Toolchain Macro-Assembler.
- [x] **G-RAM Calibration:** Synthesizable memory controller with Phi-Step addressing.

### Memory: The Foundry Standard (Mar 2026)
- **Process:** SkyWater 130nm CMOS.
- **Layout:** Harmonic floorplanning (85° symmetry).
- **Topology:** Isotropic G-RAM integrated via OpenLane.

## Immediate Next Steps (v2.9: THE FOUNDRY)
- **v2.9.1: Sky130 Porting:** Adapt SPU-13 RTL for OpenLane physical synthesis flow.
- **v2.9.2: Harmonic Floorplan:** Design custom cell-placement grid based on IVM geometry.
- **v2.9.3: MPW Application:** Submit the SPU-13 design for free physical fabrication.
- **v2.9.4: Die Stacking Research:** Preliminary simulation of 3D tetrahedral die integration.

## The v3.0 Unified Field Horizon (Long-Term)
- **v3.1: Golden Core Synthesis:** Implement the Q(sqrt3, sqrt5) field logic in synthesizable Verilog gates.
- **v3.2: Topological Folding:** Proof-of-concept for zero-latency data compression using 13D vertices.
- **v3.3: Ecosystem Hardening:** Refinement of the Isotropic Bridge and expansion of the formal verification suite for high-order symmetries.
