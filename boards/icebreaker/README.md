# iCEBreaker Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The iCEBreaker target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
```bash
# Required: Yosys / nextpnr-ice40
yosys -p "synth_ice40 -top icebreaker_top -json spu13.json" top.v ../../rtl/*.v
nextpnr-ice40 --up5k --package sg48 --pcf icebreaker.pcf --json spu13.json --asc spu13.asc
icepack spu13.asc spu13.bin
iceprog spu13.bin
```

### Pin Map
*   **LED Red:** Turbulence/Fault Detected
*   **LED Green:** Resonance Lock (Henosis)
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
