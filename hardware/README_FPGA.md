# SPU-13: Flashing the Isotropic Lattice
## Quickstart Guide for the Arty A7 Ecosystem (v2.9.25)

This guide provides the instructions for synthesizing and flashing the SPU-13 832-bit Golden Core onto the Digilent Arty A7-35T FPGA.

### 1. Prerequisites
*   **Hardware:** Digilent Arty A7-35T (Artix-7).
*   **Software:** Xilinx Vivado (ML Standard / WebPACK) 2023.x or later.
*   **Knowledge:** Basic familiarity with the Vivado Hardware Manager.

### 2. Automated Build Sequence
To ensure deterministic hardware timing and bit-perfect identity restoration, utilize the provided Tcl build script.

```bash
cd hardware
vivado -mode batch -source build_spu13.tcl
```

### 3. Programming the Silicon
1.  Connect your Arty A7 via USB.
2.  Open **Vivado Hardware Manager**.
3.  Select **Program Device** and navigate to:
    `hardware/build_output/spu13_flower.bit`
4.  Flash the bitstream.

### 4. Physical Observation
Once Henosis is achieved, the board will provide the following feedback:
*   **LED 0:** The 'Heartbeat' (61440 Hz pulse).
*   **LED 1:** Purple Glow (Identity R6=I verified).
*   **PMOD JA:** Real-time Quadray data mirror for Logic Analyzer audit.

---
*Status: DEPLOYABLE. The sunflower is ready to bloom.*
