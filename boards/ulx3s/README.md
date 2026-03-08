# ULX3S Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The ULX3S target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
```bash
# Required: Yosys / nextpnr-ecp5
yosys -p "synth_ecp5 -top ulx3s_top -json spu13.json" top.v ../../rtl/*.v
nextpnr-ecp5 --85k --package CABGA381 --json spu13.json --asc spu13.asc
ecppack spu13.asc spu13.bit
ujprog spu13.bit
```

### Pin Map
*   **LED 4:** Resonant Heartbeat (61.44 kHz)
*   **LED 7:** Turbulence/Fault Detected
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
