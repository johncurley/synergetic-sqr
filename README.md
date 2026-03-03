# synergetic-sqr
## Deterministic Spatial & High-Dimensional Transform Engine (v2.5.2)

### ⚠️ OPERATIONAL SAFETY MANDATE
The SPU-1/SPU-13 architecture produces **zero-drift spatial projections** with absolute geometric coherence. Observation of raw, bit-exact motion can cause **Topological Vertigo**. 

*   **Default Mode:** The engine launches in **Safe Mode** (Optical Damper ENABLED, Clamp 4).
*   **Forensic Override:** `./synergetic-sqr --forensic` disables dampers. **Use with caution.**
*   **High-Dimensional Warning:** SPU-11/13 shuffles are **Air-Gapped** in the RTL and restricted in software via `ETHICS.md` guidelines.

---

### Core Representation: The DQFA Epoch
The **Synergetic Processing Unit (SPU)** replaces IEEE-754 approximations with **Deterministic Quadratic Field Arithmetic (DQFA)**. 
*   **Spatial Core:** $\mathbb{Q}(\sqrt{3})$ Fixed-Point (SF32.16).
*   **Golden Core:** $\mathbb{Q}(\sqrt{3}, \sqrt{5})$ for aperiodic growth and biological simulation.
*   **G-RAM Architecture:** Memory retrieval is indexed to the **85° Absolute Node (The Monad)**. Memory access follows the **$\phi^3$ expansion** of the Pythagorean Divided Line, ensuring that data retrieval is a function of **Geometric Resonance** rather than mere electronic switching. This eliminates "Address-Jitter" and anchors the data-flow to the inertial plane.

### High-Dimensional Core (SPU-11/13)
The engine is extensible to the **Prime-11/13 basis**, enabling bit-exact tracking of 11D strings and 13D aperiodic polytopes.
*   **Topological Data Folding:** Rotate complex datasets through 13 symmetric axes with zero memory latency.
*   **Aperiodic Growth:** Native support for the **Golden Ratio ($\Phi$)** and Fibonacci-spiral memory addressing.
*   **Lattice-Native Self-Healing:** High-dimensional packing forces bit-error correction without standard ECC overhead.

### Instruction Model (SurdLang ISA)
| Instruction | Description | Implementation |
| :--- | :--- | :--- |
| `sadd` | Surd addition | Parallel integer add |
| `smul` | Surd multiplication | Integer multiply-shift |
| `srot_x4` | **SPERM_X4** | 0-cycle wire permutation |
| `equilibrate`| Laplacian Balancer | 5 Cycles | 12-neighbor lattice relaxation. |
| `damp` | **OP_DAMP** | 1 Cycle | A-Domain step-down to inertial rest. |
| `clamp` | **OP_CLAMP** | 0 Cycles | Dimensional safety path isolation. |
| `srot_13` | **SPERM_13** | 0 Cycles | 13-Axis aperiodic shuffle [RESTRICTED]. |

### Hardware Realization (SQR-ASIC)
The `hardware/` directory contains synthesizable Verilog RTL for the SPU stack:
*   **`spu_core.v`**: Integrated pipeline with ECC and Prime-Axis control.
*   **`spu_tensegrity_balancer.v`**: 4-stage pipelined Laplacian unit.
*   **`spu_ecc.v`**: SECDED Hamming protection layer.
*   **`spu_damper.v`**: A-Domain inertial rest gate.
*   **`hardware/restricted/`**: Air-gapped high-dimensional shuffle modules.

### Running the Forensic Audit
```bash
# Software Verification (Headless)
cmake -B build -S . -DBUILD_RENDERER=OFF
cmake --build build --target spu-verify spu13-verify
./build/spu-verify && ./build/spu13-verify

# Hardware Simulation (Verilog)
iverilog -o sperm_sim hardware/verilog/spu_permute_tb.v hardware/verilog/spu_permute.v
vvp sperm_sim
```

## 🌐 Theoretical Lineage
- **Algebra:** [Rational-Spread Theory](https://www.researchgate.net/profile/Andrew-Thomson) (Thomson, 2026)
- **Geometry:** [Quadray Coordinate Systems](http://www.4dsolutions.net/synergetics/quadrays.html) (Urner/Fuller)
- **Physics:** [Field Reciprocation](https://youtube.com/@KenTheoriaApophasis) (Wheeler)
- **Calculus:** [Rational Trigonometry](https://web.maths.unsw.edu.au/~norman/book.htm) (Wildberger)

## Documentation
*   **[RESEARCH.md](RESEARCH.md):** Formal stability results and fixed-point proofs.
*   **[WHITE_PAPER.md](docs/WHITE_PAPER.md):** Technical preprint on the SPU-1 architecture.
*   **[SAFETY.md](docs/SAFETY.md):** Operational guidelines for high-symmetry computing.
*   **[ETHICS.md](docs/ETHICS.md):** Responsible management of high-dimensional shuffles.
*   **[SPECIFICATION.md](hardware/specs/SPECIFICATION.md):** Formal SPU-1 ISA and register layout.
*   **[DISPLAY_ROADMAP.md](docs/DISPLAY_ROADMAP.md):** Future requirements for isotropic hardware.

## Project Roadmap
*   **v2.0 (Public Release):** Universal CI and forensic audit suite. Verified.
*   **v2.3 (High-Dimensional):** SPU-11/13 Phi-Core and Aperiodic shuffles. Verified.
*   **v2.4 (Ethical Hardening):** Safe-Mode defaults, air-gaps, and documentation alignment. Verified.
*   **v2.5 (Industry Integration):** G-RAM calibration and Robotics SDK. **IN PROGRESS.**

---
*A deterministic contribution to the global commons of computer graphics.*
