# synergetic-renderer (Metal-SQR)

A "Unified Field Engine" built on **Buckminster Fuller's Synergetic Geometry** and **Andrew Thomson's Spread-Quadray Rotors (SQR)**.

## Project Brain (Feb 2026)

### Status: v1.8 EMPIRICAL (The Scientific Verification Phase)
We have formalized the SPU-1 architecture into a technical specification and established the RTL (Register Transfer Level) requirements for the SQR-ASIC. We are now focusing on academic framing and hardware-level verification.

### Completed Milestones
- [x] **Technical Report:** Formal academic framing of the DQFA Epoch.
- [x] **RTL Specification:** ALU gate-level logic for SMUL and SNORM.
- [x] **Bit-Exact Benchmark:** Zero-drift rotation identity (65536) after 100M iterations.
- [x] **Universal Parity:** Bit-identical results across Metal, GLSL, and C++ paths.
- [x] **Purity Guard:** Build-time enforcement of the "No-Float" mandate.

### Memory: The SPU-1 Standard (Feb 2026)
- **Format:** $SF_{32.16}$ (32-bit coefficients, 16-bit shift).
- **Core:** Register shuffles for rotation; shift-and-add for surd multipliers.
- **Resilience:** Self-healing normalization via 30th-bit trigger.

## Immediate Next Steps (v1.8: EMPIRICAL)
- **Verilog Prototype:** Begin implementing the SPU-1 ALU in Verilog.
- **Formal Invariant Proof:** Develop a norm-based theorem for algebraic closure.
- **ArXiv Preprint:** Synthesize docs into a formal technical paper.
