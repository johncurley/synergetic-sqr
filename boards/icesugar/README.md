# SPU-13: iCeSugar (iCE40UP5K) Integration
## Physical Manifold Realization (v3.3.4)

This directory contains the necessary files to synthesize the SPU-13 core for the **iCeSugar** (Nano/Pro) FPGA board using the open-source **Yosys/nextpnr** toolchain.

### 1. Prerequisites
Ensure you have the following tools installed:
*   **Yosys:** Open Synthesis Suite
*   **nextpnr-ice40:** FPGA Place and Route
*   **icepack:** Bitstream generation (part of IceStorm)
*   **icesprog:** iCeSugar programming tool

### 2. File Manifest
*   **`spu13_top.v`**: Phase 1.1 Top-level module (Enable-Gated).
*   **`icesugar.pcf`**: Physical Constraint File defining pin assignments and Virtual Induction Tuning.
*   **`Makefile`**: Automation script for the synthesis flow.
*   **`icesugar_full_manifold.v`**: Full manifold implementation (Reference).

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

### 🎯 Bring-Up Checklist
Before you initiate the manifold for the first time, follow the **[Reification Checklist](CHECKLIST.md)** to ensure a safe transition from Cubic silicon to Laminar flow.

### 4. Physical IO Mapping (Phase 1.1)
*   **Red LED:** System Reset / Stall (Active when `rst_n` is low).
*   **Green LED:** Active Resonant Lock (Pulsing at 61.44 kHz).
*   **Blue LED:** Counterspace Pulse (Anti-phase to Green).
*   **Laminar Enable (Pin 11):** Authorization / Throttle. Hold High to enable the manifold flow.
*   **Janus Differential Pair (Pins 46/47):** Inductive Entry and Resonant Return. Connect to oscilloscope or twisted-pair bio-monitor.
*   **UART:** Pins 9 (RX) and 10 (TX). Stream bit-exact telemetry to the **Rust Surd-Converter**.

---
*Status: READY FOR DEPLOYMENT (Phase 1.1).*
