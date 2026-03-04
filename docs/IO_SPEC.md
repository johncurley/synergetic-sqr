# SPU-13 I/O Specification
## Physical Communication Protocols for Isotropic Systems (v2.8.2)

The SPU-13 architecture utilizes a **Radial Parallel I/O** model, optimizing data throughput for 12-connected isotropic lattices.

### 1. The 12-Neighbor Port (Isotropic Bus)
Data transfer between SPU clusters is performed via the 12-neighbor relational bus.
*   **Format:** 12 Parallel Lanes x 64-bit (768 bits per cycle).
*   **Latency:** Single-cycle propagation between adjacent silicon tiles.
*   **Physical Layer:** FMC (FPGA Mezzanine Card) or high-speed differential pairs (LVDS).

### 2. High-Fidelity Data Mirroring (PMOD JA)
For forensic verification, the most significant bits of the internal 832-bit register are mirrored to the PMOD JA header.
*   **Pin 1-8:** Mirror of `Q1[31:24]`.
*   **Usage:** Real-time monitoring via USB Logic Analyzer.

### 3. Display Boundary Interface (HDMI/VGA)
The SPU-13 dispatches 4D-to-3D projection results to an external display controller IP.
*   **Protocol:** Standard RGB888.
*   **Converter:** Hardware implementation of the `quadrayToFloat3` projection.
*   **Damping:** 16x AA (DSS) is applied at the FPGA output stage before HDMI encoding.

### 4. Direct Command Injection (Switches/Buttons)
Global state control is hard-wired to physical board interrupts.
*   **Reset:** High-priority GPIO button (Button 0).
*   **Janus Toggle:** Switch-based polarity inversion (Switch 0).

---
*Status: I/O FINALIZED. Silicon communication protocols active.*
