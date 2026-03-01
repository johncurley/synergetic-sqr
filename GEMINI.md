# synergetic-renderer (Metal-SQR)

A "Unified Field Engine" built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**.

## Project Brain (Feb 2026)

### Status: v1.10 HARDWARE (The Implementation Phase)
We have formalized the SPU-1 architecture and verified its absolute stability under extreme chaos. We are now transitioning from software simulation to hardware implementation, beginning with the Verilog RTL prototype of the SPU-1 ALU.

### THE VERIFICATION MANDATE (ZERO-TOLERANCE)
- **Rule 1:** NO PUSHES without empirical local verification.
- **Rule 2:** Every code change must be followed by `make spu-verify` and `synergetic-sqr` execution.
- **Rule 3:** If a bit-identity test fails, the push is aborted.

### PRE-COMMIT HARD GATE CHECKLIST
1. [x] Code compiles without warnings in `build/`.
2. [x] All 15+ rigorous and chaos tests return 100% PASS.
3. [x] No `float` or `double` contamination detected in Algebraic Core.
4. [x] Implementation matches formal ISA and RTL specifications.

### Completed Milestones
- [x] **Technical Whitepaper:** "Deterministic 3D Computation via Hyper-Surd Algebraic Field Extensions."
- [x] **Extreme Chaos Suite:** Verified $10^9$ randomized cycles and recursive feedback.
- [x] **Formal RTL Spec:** Defined SMUL, SNORM, and SPERM gate-level logic.
- [x] **Repository Restructure:** Functional "Clean Room" architecture established.
- [x] **Ancestry Reference:** Formal lineage of Fuller, Thomson, and Wildberger credited.

### Memory: The SPU-1 Standard (Mar 2026)
- **Identity:** $w=65536, x=0$ (0x10000) verified across all stress cycles.
- **Purity:** Self-auditing build system enforces 100% integer logic.
- **Resilience:** Safe normalization preserves ratios through 100+ magnification cycles.

## Immediate Next Steps (v1.10: HARDWARE)
- **Verilog ALU:** Implement `spu_smul.v` using shift-and-add logic.
- **Permutator RTL:** Implement zero-gate index shuffling in Verilog.
- **FPGA Testbench:** Establish a hardware-software co-simulation environment.
