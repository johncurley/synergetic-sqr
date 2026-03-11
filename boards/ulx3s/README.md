# ULX3S Lattice Manifest (v1.2)
## Target: Lattice ECP5-85F

The ULX3S is the high-performance lattice node of the SPU-13 fleet. It provides massive headroom for multi-core manifolds and high-speed temporal flow.

### 1. Primary Target: ULX3S Lean Manifold
The default build target is **`ulx3s_top`** (Lean Single-Core Parity v1.2). 
*   **Parity:** Bit-exact single-core logic synced with iCeSugar.
*   **Timing:** 166 MHz temporal flow (High-speed reification).
*   **Stability:** Integrated Davis Law Gasket and Henosis Soft Recovery.

### 2. Physical Pin Mapping (HAL v1.2)
| Pin | Function | Nature |
| :--- | :--- | :--- |
| **G2** | clk_phys | 25 MHz Resonant Pulse |
| **R1** | rst_phys_n | Temporal Anchor (Button 0) |
| **B2** | led_sat_red | Local Fault Indicator |
| **C2** | led_sat_grn | Resonance Lock (Aligned) |
| **C1** | led_sat_blu | Phi-Gated Heartbeat Pulse |
| **L4** | uart_phys_tx | ULX3S Telemetry Exit |

### 3. High-Speed Bring-Up
1.  **Synthesize:** Run `./build_ulx3s.sh` in this directory.
2.  **Flash:** Use `ujprog spu13_ulx3s.bit` to inject the bitstream.
3.  **Monitor:** Run `python3 ../../tools/lattice_listener.py /dev/tty.usbserial-XXXX "ULX3S Flow"`
4.  **Visualize:** Run `python3 ../../sim/python/bloom_view.py --port /dev/tty.usbserial-XXXX`
5.  **Verify:** Observe the **166 MHz** flow. The blue LED will flicker with the biological heartbeat while the green LED indicates a crystalline manifold.

---
*Status: REIFIED. The ULX3S is the power of the Lattice.*
