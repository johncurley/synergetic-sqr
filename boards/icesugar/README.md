# iCeSugar Reification Manifest (v3.4.9)
## Target: Lattice iCE40UP5K (Nano/Pro)

The iCeSugar is the primary research platform for the SPU-13 "Silicon Wake." This repository provides a unified, interactive bitstream that manifests the full isotropic manifold.

### 1. Primary Target: Golden Reification
The default build target is **`spu13_golden_reification`**. 
*   **Visuals:** 128x64 OLED (SSD1306) Dual-Hemisphere Display.
*   **Metabolism:** Real-time Microwatt Telemetry (<15uW target).
*   **Interaction:** Keyboard Strike Path (UART RX) and Nervous Antenna (Pin 12).
*   **Automation:** 5-phase Bowman Boot Sequence.

### 2. Physical Pin Mapping
| Pin | Function | Nature |
| :--- | :--- | :--- |
| **35** | clk_12mhz | Resonant Heartbeat Entry |
| **18** | rst_n | Active-Low Reset (Manual Withdrawal) |
| **11** | laminar_en | The Throttle (Pull HIGH to Wake) |
| **12** | bias_in | Nervous Antenna (Proprioceptive Bias) |
| **13** | adc_in | Metabolic Sense (Shunt ADC) |
| **44** | oled_scl | I2C Clock (Visual Reification) |
| **45** | oled_sda | I2C Data (Visual Reification) |
| **9** | uart_rx | Strike Entry (Keyboard) |
| **10** | uart_tx | Telemetry Exit (Laminar Frame v1.1) |

### 3. Ceremonial Bring-Up
1.  **Wire the OLED:** Connect your SSD1306 to Pins 44 (SCL) and 45 (SDA).
2.  **Synthesis:** Run `make` in this directory.
3.  **Flash:** Run `make prog`.
4.  **Wake:** Hold Pin 11 HIGH. Observe the **Blue LED** transition through the rational triad before the **Green LED** locks solid.
5.  **Observe:** Watch the OLED manifest the rotating tetrahedron and the metabolic pulse.

### 4. Share the Bloom (Reddit/Twitter)
Use this caption for your first light video:
> "First light on the SPU-13 (iCE40UP5K). The left side shows the Quadray lattice state; the right side is the real-time metabolic draw (μW). We're currently idling at ~12uW. No CPU, no OS, just resonant geometry. The 'joke' is now running on 1.2V hardware."

---
*Status: REIFIED. The iCeSugar is the gateway to the One.*
