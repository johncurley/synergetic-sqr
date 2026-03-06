# TinyFPGA BX Target Support
## Ultra-Minimalist iCE40 Synthesis

### Build Instructions
```bash
yosys -p "synth_ice40 -top tinyfpga_bx_top -json top.json" ../../rtl/*.v top.v
nextpnr-ice40 --lp8k --package cm81 --json top.json --pcf tinyfpga_bx.pcf --asc top.asc
icepack top.asc top.bin
tinyprog -p top.bin
```
### Verification
*   **User LED:** Pulsing indicates **Resonance Lock**.
