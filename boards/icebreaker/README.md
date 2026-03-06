# iCEBreaker Target Support
## Open-Source Toolchain Synthesis

### Build Instructions
```bash
yosys -p "synth_ice40 -top icebreaker_top -json top.json" ../../rtl/*.v top.v
nextpnr-ice40 --up5k --package sg48 --json top.json --pcf icebreaker.pcf --asc top.asc
icepack top.asc top.bin
```
### Verification
*   **LED Green:** Resonance Lock
*   **LED Red:** Fault Detected
