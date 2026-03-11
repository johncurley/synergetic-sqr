# iCeSugar Cortex Manifest (v1.2)
## Target: Lattice iCE40UP5K (Standard iCeSugar)

The iCeSugar Cortex is the high-fidelity hub of the SPU-13 fleet. It integrates global telemetry, recursive memory, and the physical "Lithic Artery."

### 1. Primary Target: SPU-13 Cortex
The default build target is **`top`** (SPU-13 Cortex v1.2). 
*   **Heartbeat:** Fibonacci-stepped Biological Heartbeat.
*   **Artery:** 60-degree branching energy distribution (Lithic Artery).
*   **Memory:** 128KB SPRAM-based Fractal Dream Log.
*   **Stability:** Pipelined Davis Law Gasket with Symmetric Soft Recovery.

### 2. Physical Pin Mapping (HAL v1.4)
| Pin | Function | Nature |
| :--- | :--- | :--- |
| **35** | clk_phys | Resonant Pulse (Global Buffer Input) |
| **18** | rst_phys_n | Temporal Anchor (Reset) |
| **10** | manual_tuck | Physical Henosis Override (Active Low) |
| **14** | uart_phys_tx | Cortex Telemetry Exit (Vitals Stream) |
| **43** | oled_scl | OLED I2C Clock (Visual Breath) |
| **38** | oled_sda | OLED I2C Data (Visual Breath) |
| **44** | audio_out | Harmonic Voice (PWM Audio) |
| **48** | eink_cs | E-Ink SPI Chip Select (Lithic Soul) |
| **45** | eink_sck | E-Ink SPI Clock |
| **46** | eink_mosi | E-Ink SPI MOSI |
| **2**  | l_clk | **Laminar Input Clock** (Zero-Latency) |
| **47** | l_dat | **Laminar Input Data** (Zero-Latency) |

### 3. Ceremonial Bring-Up
1.  **Synthesize:** Run `./build_spu13.sh top` in this directory.
2.  **Flash:** Drag and drop `spu13_cortex.bin` into the iCELink virtual disk.
3.  **Monitor:** Open your terminal at 115200 baud to hear the **Vocal Cords** (H=Happy, S=Stressed, R=Recovery).
4.  **Calibrate:** Press `+` or `-` in your terminal to adjust the manifold's **Sanity Threshold** in real-time.

---
*Status: REIFIED. The iCeSugar is the mind of the Manifold.*
