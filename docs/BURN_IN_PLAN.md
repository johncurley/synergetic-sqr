# SPU-13 Physical Burn-In Plan (v1.0)

This document specifies the exact test protocol for validating the long-term stability and resilience of the SPU-13 on physical hardware.

## 1. Target Board
-   **Board:** Arty A7-35T (or A7-100T for expanded thermal testing)

## 2. Bitstream
-   **Path:** `build/arty_a7_top.bit`
-   **Logic:** The bitstream must contain the full SPU-13 core, including the Davis gate recovery module and the `spu_core` logic.

## 3. Test Conditions
-   **Clock:** 100 MHz
-   **Duration:** 24 hours continuous operation
-   **Workload:** The FPGA will run a continuous "Golden Angle" loop, feeding the SPU-13 core a sequence of irrational rotations derived from the Phi constant. This ensures a chaotic but deterministic workload that stresses all computational paths.

## 4. Observables
The following metrics will be monitored via UART and on-board LEDs:

*   **"Alive" Heartbeat:** The primary status LED will blink once per second to indicate that the main clock and control loop are active.
*   **Davis Gate Events:**
    *   An `over_curvature` event (LED 2) indicates a transient fault was detected.
    *   A `recovery` event (LED 3) indicates the Davis gate successfully restored manifold integrity.
*   **Davis Ratio Snapshots (UART):** Once per minute, the FPGA will transmit a snapshot of the current Davis ratio, allowing for a time-series analysis of the system's stability. Any deviation from the "Golden Mean" indicates a potential logic error or thermal drift.
