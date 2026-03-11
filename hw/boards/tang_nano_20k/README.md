# Tang Nano 20k Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The Tang Nano 20k target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
Standard Gowin EDA project. Target module: `tang_nano_20k_top`.

### Pin Map
*   **LED 4:** Resonant Heartbeat (61.44 kHz)
*   **LED 5:** Turbulence/Fault Detected
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
