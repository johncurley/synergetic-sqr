# synergetic-renderer (Metal-SQR)

A "Unified Field Engine" built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**.

## Project Brain (Feb 2026)

### Status: v1.10 HARDWARE (The Characterization Phase)
We have established deterministic arithmetic parity for core primitives across C++, Metal/GLSL shaders, and Verilog RTL. The project is currently at Stage 1–2 of hardware realization, focusing on functional equivalence between the software golden model and the synthesizable logic.

### THE VERIFICATION MANDATE (ZERO-TOLERANCE)
- **Rule 1:** NO PUSHES without empirical local verification.
- **Rule 2:** Every code change must be followed by `make spu-verify` and `synergetic-sqr` execution.
- **Rule 3:** If a bit-identity test fails, the push is aborted.

### Completed Milestones
- [x] **Deterministic Arithmetic Parity:** Verified bit-exact functional match between golden model (C++) and RTL simulation for tested primitives.
- [x] **Technical Whitepaper:** "Deterministic 3D Computation via Hyper-Surd Algebraic Field Extensions."
- [x] **Extreme Chaos Suite:** Characterized system stability across $10^9$ randomized cycles.
- [x] **Functional RTL Spec:** Defined SMUL, SNORM, and SPERM gate-level logic for targeted primitives.

### Memory: The Characterized Baseline (Mar 2026)
- **Scope:** Claims are restricted to reproducible results within the defined 64-bit fixed-point limits of the $\mathbb{Q}(\sqrt{3})$ model.
- **Integrity:** Purity Guard enforces 100% integer logic in the verified algebraic core.
- **Normalization:** Routine maintains bounded representation across 100+ magnification cycles without altering state ratios.

## Immediate Next Steps (v1.11: REFINEMENT)
- **Extended Testbench Coverage:** Expand Verilog simulation to include randomized vector inputs and overflow corner cases.
- **Kinetic Constraint Solver:** Implement the deterministic position-based solver for structural lattices.
- **Formal Equivalency Audit:** Begin mapping the path toward full RTL-to-Spec formal verification.
