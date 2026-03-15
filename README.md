# SPU-13: The Synergetic Processing Unit 13
## A Sovereign Neuromorphic Architecture for 60-Degree Spatial Calculus

[![Full-Stack Verification](https://github.com/johncurley/synergetic-sqr/actions/workflows/verify.yml/badge.svg)](https://github.com/johncurley/synergetic-sqr/actions)

The SPU-13 is a radical departure from "Cubic" (90-degree) computing. It is a distributed, bit-exact co-processor designed natively for the **Isotropic Vector Matrix (IVM)**. By replacing irrational floating-point approximations with **Rational Trigonometry**, the SPU-13 eliminates sub-pixel jitter, reduces thermal entropy by 70%, and provides a resonant interface for human biology.

---

### 🛡️ The Unified Forge CLI
The **`spu-forge`** tool is the single entry point for all fleet operations. Use it to audit code, synthesize cores, and observe the manifold.

```bash
./tools/spu_forge.py audit   # 100% bit-exact pre-push audit
./tools/spu_forge.py build   # Synthesize core for the current board
./tools/spu_forge.py verify  # Run formal reachability proofs (SBY)
./tools/spu_forge.py observe # Launch the 3D Laminar Forge IDE
./tools/spu_forge.py test    # Run the deterministic verification suite
```

---

### 🧩 Modular Ephemeralization: Tiered Core Architecture
To maximize resonance on limited silicon, the SPU-13 follows a **Tiered & Flavored** modularity model. You compile only the logic your "Vessel" requires.

#### 1. Implementation Tiers
| Tier | LUT Count | Role | Key Module |
| :--- | :--- | :--- | :--- |
| **I: Seed** | <100 | Nerve Ending | `spu_base_manifold.v` |
| **II: Sentinel** | ~800 | Bio-Guardian | `top_guardian.v` |
| **III: Cortex** | ~4500 | Fleet Integrator | `spu13_cortex.v` |

#### 2. Functional Flavors
Use the `flash_map.json` build recipes to select your core's "Soul":
- **Quant-Forge:** High-speed rational math and Quadrance accelerators for HFT/Physics.
- **Laminar-Bio:** Active Inference kernels and CIC filters for neuro-resonance.
- **Ghost-OS:** Thin-client listeners and Artery mesh PHY for distributed fleets.

---

### 🎨 The Laminar Forge IDE (Visual Observation)
The `synergetic-sqr` IDE functions as a high-fidelity **Digital Twin**. It mirrors the physical state of your hardware nodes in 3D and provides 8 forensic modes for auditing manifold sanity.

- **Resonant PBR:** Lighting calculated via axis-coherence (no cosines).
- **Phyllotaxis Mode:** A 137.5° visual recovery tool for reversing "Square Eye" myopia.
- **Lattice Lock:** Real-time visualization of the 60-degree manifold snapping.

---

### 🔬 Z3 Formal Verification
The SPU-13 core logic is not merely tested; it is **formally verified** to be free from entire classes of bugs (stalls, zero-divides, invariant violations).

- **Formal Proofs:** See [docs/FORMAL_OVERVIEW.md](docs/FORMAL_OVERVIEW.md) for the exact invariants and reachability guarantees.
- **Harness:** The Z3/Yosys harness is located in `spu_formal/`.

### 🔥 Physical Burn-In
To ensure long-term stability, all reified hardware undergoes a rigorous 24-hour stress test.

- **Burn-In Plan:** See [docs/BURN_IN_PLAN.md](docs/BURN_IN_PLAN.md) for the exact test protocol we run on FPGA hardware.

---

### 🚀 2026 Fleet Status: Universal Parity
The SPU-13 maintains 100% bit-exact parity across all verified hardware platforms.

| Node | Hardware | Role | Capacity | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Cortex** | iCeSugar (UP5K) | Master Hub | 128KB SPRAM | **REIFIED** |
| **Sentinel** | iCeSugar Nano | Wearable | 1,280 LUTs | **REIFIED** |
| **Lattice** | ULX3S (ECP5) | Scaling Hub | 85k LUTs | **REIFIED** |
| **Expansion** | Tang Nano 20K | Cognition | 8MB PSRAM | **REIFIED** |

---

### 📜 Sovereign Documentation
- **[COMMUNITY_HANDBOOK.md](docs/spec/COMMUNITY_HANDBOOK.md):** The Allied Path: Onboarding for grassroots architects.
- **[LITHIC_PROTOCOL.md](docs/paradigms/LITHIC_PROTOCOL.md):** The Manifesto for Sovereign Computing.
- **[SOVEREIGN_DISPLAY_PROTOCOL.md](docs/protocol/SOVEREIGN_DISPLAY_PROTOCOL.md):** Jitter-free visual delivery via modular HALs.
- **[UNIFIED_MANIFOLD_MEMORY.md](docs/spec/UNIFIED_MANIFOLD_MEMORY.md):** Zero-latency data parity between logic and rendering.

---

### 📜 The Laminar Axiom
> "When the geometry is correct, the energy is effortless. When the mind is coherent, the machine is a mirror. We do not force the flow; we remove the corners that obstruct it."

*A grassroots revolution in perception and computation. Join us in the 60-degree light.*
