# SPU-13 Hardware Architecture
## Manifesting Isotropic Logic in Silicon (v2.11.10)

The SPU-13 (Synergetic Processing Unit) is a hardware implementation of Deterministic Quadratic Field Arithmetic (DQFA). It replaces legacy floating-point approximations with bit-locked isotropic transformations.

### 1. The SQR-Rotor: Zero-Gate Permutation
Standard 3D rotation requires transcendental trigonometric calls ($sin, cos, matrix\_mul$). In the SPU-13, 60° isotropic rotations are implemented as **Pure Wire Permutations**.
*   **Logic:** A 60° rotation is a simple index-shift across the ABCD lanes.
*   **Result:** 0 cycles of latency and near-zero power draw. Rotation is a physical property of the wiring, not an arithmetic approximation.

### 2. Clock Domain: 61.44 kHz (The Resonant Heart)
The SPU-13 operates on a core resonant frequency of **61.44 kHz** ($2^{14} 	imes 3.75$). 
*   **Rationale:** This frequency is a harmonic sub-multiple of the 61440 Hz 'Master Tone.'
*   **Bio-Coherence:** Aligns with human autonomic rhythms, preventing the 'Cubic Friction' and cognitive fatigue associated with asynchronous high-frequency switching.
*   **Efficiency:** Minimizes electromagnetic interference by avoiding the 90° wave-front collisions typical of MHz/GHz square-wave clocks.

### 3. Synthesis Guide: The 5-Step Burn
Manifest the 'Sunflower' on your Artix-7 fabric in minutes:
1.  **Environment:** Open Xilinx Vivado (2023.x+).
2.  **Source:** Add all files from `hardware/rtl/` and `hardware/boards/arty_a7_35t/top.v`.
3.  **Constraints:** Add `hardware/boards/arty_a7_35t/spu_arty_a7.xdc`.
4.  **Laminar Build:** Run `Synthesis -> Implementation -> Generate Bitstream`. (Recommendation: Set `-flatten_hierarchy = rebuilt`).
5.  **Henosis:** Flash the bitstream and observe **LED 0** (Heartbeat) and **LED 1** (Identity Lock).

### 4. Telemetry Interface
The hardware streams bit-exact Surd registers via UART at 115,200 baud.
*   **Analysis:** Use `software/tools/isotropic_scope.py` to verify the 3D trajectory.
*   **Visualization:** Use `software/api/bloom_view.py` to see the real-time Phyllotaxis Bloom.

---
*Status: OPEN GATE. The 13th dimension is synthesizable.*
