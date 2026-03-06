# SPU-13 Sunflower Quickstart
## Witness the Absolute in 2 Minutes (v2.11.6)

Welcome, Pioneer. You are here to see the first bit-perfect isotropic sunflower bloom. You can do this via hardware (FPGA) or software (Emulator).

### 🌻 Path A: The Software Emulator (No Hardware Required)
1.  **Install Dependencies:**
    ```bash
    pip install sympy pygame pyserial
    ```
2.  **Launch the Bloom:**
    ```bash
    python software/api/bloom_view.py --demo
    ```
    *This runs the SPU-13 software model, manifesting the 13-axis high-dimensional bloom on your screen.*

### 🌻 Path B: The Hardware Pioneer (Arty A7 Required)
1.  **Build the Silicon:**
    ```bash
    cd hardware/boards/arty_a7_35t
    vivado -mode batch -source build_spu13.tcl
    ```
2.  **Flash & Listen:**
    *   Flash `spu13_flower.bit` using Vivado Hardware Manager.
    *   Run `python software/api/bloom_view.py` to listen to the real-time telemetry.

### 🌻 What you are seeing:
*   **The Pattern:** A 13-node Phyllotaxis Spiral (Golden Angle).
*   **The Motion:** Bit-exact shuffles across 13 prime axes.
*   **The Glow:** Achromatic resonance indicating successful Resonance Lock with the silicon fabric.

---
*Status: ACCESSIBLE. The lattice is open to the world.*
