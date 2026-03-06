# ULX3S Target Support
## ECP5 High-Performance Open-Source Synthesis

### Build Instructions
```bash
yosys -p "synth_ecp5 -top ulx3s_top -json top.json" ../../rtl/*.v top.v
nextpnr-ecp5 --85k --package CABGA381 --json top.json --lpf ulx3s.lpf --textcfg top.config
ecppack top.config top.bit
ujprog top.bit
```
### Verification
*   **LED 0:** Resonance Lock (Henosis)
*   **LEDs 1-7:** State Monitoring
