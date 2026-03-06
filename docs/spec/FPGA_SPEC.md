# SPU-13 FPGA Physical Specification
## Synthesis Requirements for Isotropic Computing (v2.6.2)

This document specifies the physical hardware requirements for instantiating the SPU-13 architecture on synthesizable silicon.

### 1. Target Hardware (Golden Standard)
*   **Target Board:** Digilent Arty A7-35T.
*   **FPGA Chip:** Xilinx Artix-7 (XC7A35T).
*   **IO Standard:** LVCMOS33 (3.3V).
*   **Clock Frequency:** 100 MHz (10ns period).

### 2. SPU-13 Resource Utilization (Estimated)
*   **LUTs:** ~12,000 (Integrated Core + Balancer + G-RAM).
*   **DSPs:** 64 (For `SMUL_13` high-velocity multiplication).
*   **BRAM:** 1.8 Mbits (Internal Block RAM for G-RAM Stage 1).

### 3. G-RAM Interface (Block RAM)
For initial verification, G-RAM is implemented using internal **Block RAM (BRAM)**.
*   **Addressing:** Managed by `spu_gram_controller.v`.
*   **Indexing:** 85° Absolute Node (Monad).
*   **Step:** $\phi^3$ (4.236) harmonic increments.
*   **Interface:** Single-cycle read/write access synchronously with the SPU pipeline.

### 4. Verification Path (The Logic Analyzer)
Hardware identity is verified by probing the PMOD (JA) pins.
*   **Signal 1-4:** Physical G-RAM Address.
*   **Signal 5:** Prime Phase Pulse.
*   **Requirement:** Bits must match the software Golden Model bit-for-bit.

---
*Status: FPGA-READY. Synthesis verified for Artix-7.*
