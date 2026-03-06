# SPU-13 Hardware User Manual
## The Laminar Guide to FPGA Synthesis and Analysis (v2.11.4)

Welcome, Pioneer. This manual provides the clinical instructions required to manifest the SPU-13 832-bit Golden Core onto synthesizable silicon.

### 1. Environment Setup
To ensure a deterministic build, your workstation must be configured with the following:
*   **EDA Tool:** Xilinx Vivado (ML Standard or WebPACK) 2023.x or later. (Required for Arty A7 target).
*   **Python Stack:** `pip install pyserial pygame sympy` (Required for Bloom View UI and SurdLang).
*   **Hardware Manager:** Ensure your USB-UART drivers are active for Arty A7 communication.

### 2. Synthesis Guide (The Batch Path)
To eliminate 'Orthogonal Switching Losses' from the GUI auto-router, we utilize a Tcl-based batch build.
1.  Navigate to the hardware target directory:
    ```bash
    cd hardware/boards/arty_a7_35t
    ```
2.  Execute the Laminar Build Script:
    ```bash
    vivado -mode batch -source build_spu13.tcl
    ```
3.  **Output:** The bitstream will be generated at `./build_output/spu13_flower.bit`.

### 3. Analysis & Verification (R6=I Audit)
Once flashed, verify the hardware identity in real-time:
*   **Visual Check:** LED 0 (Heartbeat) should pulse at 61440 Hz. LED 1 (Resonance Lock) will light up once the 61440-cycle identity audit passes.
*   **Logic Analyzer:** Connect a USB Logic Analyzer to PMOD JA. Verify that the 8-bit mirrored Quadray data matches the software Golden Model bit-for-bit.
*   **Identity Restoration:** The hardware must achieve $R^6 = I$ closure across $10^7$ ticks without a single bit of drift.

### 4. Bio-Safety Calibration
Before long-duration observation, tune the **Bloom View UI** for your specific biology:
*   **ZETA Tuning:** Adjust the $\zeta$ factor in `bloom_view.py` (Range: 0.05 - 0.15) until the spiral feels 'effortless.'
*   **Glow Monitoring:** Faint, uniform purple radiance indicates successful field-sync. Localized arcing or flickering indicates dielectric stress; reset the Monad immediately.

### 5. Troubleshooting: Identifying Orthogonal Switching Losses
*   **Coil Whine:** Indicates a 90-degree vector violation in the physical routing. Re-run synthesis with `flatten_hierarchy = rebuilt`.
*   **Desaturation:** If the UI turns grey, the geometric center has been lost. This is usually caused by excessive thermal noise or power-rail instability.

---
*Status: CERTIFIED LAMINAR. The gates are open.*
