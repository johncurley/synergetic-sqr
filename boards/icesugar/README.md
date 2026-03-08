# SPU-13: iCeSugar (iCE40UP5K) Integration
## Physical Manifold Realization (v3.1.32)

This directory contains the necessary files to synthesize the SPU-13 core for the **iCeSugar** (Nano/Pro) FPGA board using the open-source **Yosys/nextpnr** toolchain.

### 1. Prerequisites
Ensure you have the following tools installed:
*   **Yosys:** Open Synthesis Suite
*   **nextpnr-ice40:** FPGA Place and Route
*   **icepack:** Bitstream generation (part of IceStorm)
*   **icesprog:** iCeSugar programming tool

### 2. File Manifest
*   **`top.v`**: Top-level module mapping the SPU-13 core to iCeSugar IO.
*   **`icesugar.pcf`**: Physical Constraint File defining pin assignments.
*   **`Makefile`**: Automation script for the synthesis flow.

### 3. Synthesis and Programming
To build the bitstream and flash it to the board:

```bash
# 1. Navigate to the board directory
cd boards/icesugar

# 2. Synthesize and generate bitstream
make

# 3. Flash to iCeSugar (ensure board is connected via USB-C)
make prog
```

### 4. Physical IO Mapping
*   **Red LED:** Turbulence/Fault detected in the manifold.
*   **Green LED:** Resonance Lock achieved.
*   **Blue LED:** Phase Heartbeat (Resonant Clock).
*   **Janus Differential Pair:** Pins 46 (+) and 47 (-). Connect to oscilloscope or bio-monitor.
*   **UART:** Pins 9 (RX) and 10 (TX). Stream bit-exact telemetry to the **Rust Surd-Converter**.

---
*Status: READY FOR SILICON.*
