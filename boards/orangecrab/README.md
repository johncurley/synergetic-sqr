# OrangeCrab Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The OrangeCrab target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
```bash
# Required: Yosys / nextpnr-ecp5
yosys -p "synth_ecp5 -top orangecrab_top -json spu13.json" top.v ../../rtl/*.v
nextpnr-ecp5 --25k --package CSFBGA285 --json spu13.json --asc spu13.asc
ecppack spu13.asc spu13.bit
dfu-util -D spu13.bit -a 0
```

### Pin Map
*   **LED RGB (Green):** Resonant Heartbeat (61.44 kHz)
*   **LED RGB (Red):** Turbulence/Fault Detected
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
