# OrangeCrab Target Support
## ECP5 Open-Source Toolchain (Feather Format)

### Build Instructions
```bash
yosys -p "synth_ecp5 -top orangecrab_top -json top.json" ../../rtl/*.v top.v
nextpnr-ecp5 --25k --package CSFBGA285 --json top.json --lpf orangecrab.lpf --textcfg top.config
ecppack --compress top.config top.bit
```
### Verification
*   **LED Red:** Fault Detected
*   **LED Green:** Resonance Lock
*   **LED Blue:** Heartbeat (48MHz)
