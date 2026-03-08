# TinyFPGA BX Target Support
## SPU-13 Universal Fractal Heart (v3.1.36)

The TinyFPGA BX target is synchronized to the **61.44 kHz** resonant manifold using the **Sierpiński Fractal Oscillator**.

### Build Instructions
```bash
# Required: Yosys / nextpnr-ice40
yosys -p "synth_ice40 -top tinyfpga_bx_top -json spu13.json" top.v ../../rtl/*.v
nextpnr-ice40 --lp8k --package cm81 --json spu13.json --asc spu13.asc
icepack spu13.asc spu13.bin
tinyprog -p spu13.bin
```

### Pin Map
*   **LED:** Resonant Heartbeat (61.44 kHz pulse)
*   **UART:** Bit-exact telemetry to the **Rust Surd-Converter**.
