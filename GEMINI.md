# synergetic-renderer (Metal-SQR)

A "Unified Field Engine" built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**.

## Project Brain (Feb 2026)

### Status: v1.8 KINETIC (The Tensegrity Dynamics Phase)
We have moved from a static coordinate system to a dynamic physical system. We are now formalizing "Force" and "Tension" as integer-based Quadray vector balances within the Isotropic Vector Matrix (IVM).

### THE VERIFICATION MANDATE (ZERO-TOLERANCE)
- **Rule 1:** NO PUSHES without empirical local verification.
- **Rule 2:** Every code change must be followed by `make spu-verify` and `synergetic-sqr` execution.
- **Rule 3:** If a bit-identity test fails, the push is aborted.

### PRE-COMMIT HARD GATE CHECKLIST
1. [ ] Code compiles without warnings in `build/`.
2. [ ] `./spu-verify` returns 100% PASS on all tests (1-7).
3. [ ] `./synergetic-sqr` console output confirms Identity Closure.
4. [ ] No `float` or `double` contamination detected in Algebraic Core.
5. [ ] Logic is verified bit-for-bit against algebraic expectations.

### Completed Milestones
- [x] **Technical Report:** Formal academic framing of the DQFA Epoch.
- [x] **RTL Specification:** ALU gate-level logic for SMUL and SNORM.
- [x] **Tensegrity Primitives:** Implementation of `TensegrityNode` and `TensegrityLink`.
- [x] **Equilibrium Logic:** Bit-exact Quadray force-balance verification.
- [x] **Jitterbug Intrinsic:** Added `_spu_jitterbug` instruction placeholder.

### Memory: The Kinetic Standard (Mar 2026)
- **Equilibrium:** Net force is zero if all Quadray coordinates are bit-identical.
- **Tension:** Defined as integer displacement (Quadrance) between nodes.
- **Stability:** "Snap-to-Truth" logic prevents sub-rational position drift.

## Immediate Next Steps (v1.8: KINETIC)
- **Tensegrity Solver:** Implement a deterministic spring-force solver using `DualSurd`.
- **Kinetic Kernel:** Update GLSL/Metal kernels to simulate structural deformation.
- **Verilog Prototype:** Translate `_spu_add_q4` and `_spu_rotate_60` into RTL.
