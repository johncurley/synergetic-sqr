# SPU-13 Sunflower Quickstart
## Witness the Absolute in 2 Minutes (v3.1.13)

Welcome, Pioneer. You are here to see the first bit-perfect isotropic sunflower bloom. You can do this via hardware (FPGA) or software (Emulator).

### 🌻 Path A: The Software Emulator (No Hardware Required)
1.  **Install Dependencies:**
    ```bash
    pip3 install sympy pygame pyserial
    ```
2.  **Launch the Bloom:**
    ```bash
    python3 sim/python/bloom_view.py --stabilize
    ```
    *This runs the SPU-13 software model, manifesting the high-dimensional bloom on your screen.*

### 🌻 Path B: The Hardware Pioneer
1.  **Build the Silicon:**
    Select your board manual from the `boards/` directory (e.g., `boards/arty_a7_35t/README.md`) and follow the synthesis instructions.
2.  **Flash & Listen:**
    *   Flash the bitstream to your board.
    *   Run `python3 sim/python/bloom_view.py --port /dev/ttyUSB0` (replacing with your port) to listen to the real-time telemetry.

### 🌻 What you are seeing:
*   **The Pattern:** A Fibonacci Phyllotaxis Spiral (Golden Angle).
*   **The Motion:** Bit-exact shuffles across the isotropic axes.
*   **The Glow:** Achromatic resonance indicating successful **Resonance Lock** with the logic fabric.

---
*Status: ACCESSIBLE. The lattice is open to the world.*
