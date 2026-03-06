# SPU-13 Sunflower Quickstart
## Witness the Absolute in 2 Minutes (v3.1.17)

Welcome, Pioneer. You are here to see the first bit-perfect isotropic sunflower bloom. We recommend using a virtual environment to isolate the SPU-13 signal from your system's package manager.

### 🌻 Path A: The Software Emulator (No Hardware Required)
1.  **Initialize the Isotropic Buffer:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```
2.  **Install Dependencies:**
    ```bash
    pip3 install sympy pygame pyserial
    ```
3.  **Launch the Bloom:**
    ```bash
    python3 sim/python/bloom_view.py --stabilize
    ```
    *This runs the SPU-13 software model, manifesting the high-dimensional bloom on your screen.*

### 🌻 Path B: The Hardware Pioneer
1.  **Build the Silicon:**
    Select your board manual from the `boards/` directory (e.g., `boards/arty_a7_35t/README.md`) and follow the synthesis instructions.
2.  **Activate Telemetry Bridge:**
    *Ensure your venv is active (Step 1 above)*.
    ```bash
    python3 sim/python/bloom_view.py --port /dev/ttyUSB0
    ```

### 🌻 What you are seeing:
*   **The Pattern:** A Fibonacci Phyllotaxis Spiral (Golden Angle).
*   **The Motion:** Bit-exact shuffles across the isotropic axes.
*   **The Glow:** Achromatic resonance indicating successful **Resonance Lock** with the logic fabric.

---
*Status: ISOLATED. The environment remains pure.*
