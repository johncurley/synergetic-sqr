# Arty A7-35T Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The Arty A7 target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
```bash
vivado -mode batch -source build_spu13.tcl
```

### Pin Map
*   **LED 0:** Resonant Heartbeat (61.44 kHz pulse)
*   **LED 1:** Resonance Lock (Henosis)
*   **PMOD JA:** Forensic Audit Bus
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
