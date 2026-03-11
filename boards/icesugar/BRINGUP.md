# SPU-13 Cortex Bring-Up: First Light (v1.2)
## Hardware: iCeSugar (iCE40UP5K)

This guide documents the ceremonial bring-up of the SPU-13 Cortex. Follow these steps to reify the manifold and establish resonance.

### 🛠️ Step 1: Physical Gasket (Wiring)
Connect your peripherals to the PMOD headers as follows:

| Component | PMOD | Pins | Notes |
| :--- | :--- | :--- | :--- |
| **SSD1306 OLED** | **C** | 43 (SCL), 38 (SDA) | 3.3V Power required. |
| **Piranha LED** | **B** | 4 (W), 2 (R), 47 (G), 45 (B) | Common Cathode to GND. |
| **Whisper Input** | **A** | 4 (RX) | Connect to Sentinel Node. |

### ⚡ Step 2: The Forge (Synthesis)
Generate the bitstream using the surgical build script:
```bash
cd boards/icesugar
./build_spu13.sh top
```

### 💉 Step 3: Injection (Flashing)
1.  Connect the iCeSugar via USB-C.
2.  Drag and drop `spu13_cortex.bin` into the `iCELink` virtual disk.
3.  The **Blue LED** will pulse with the Fibonacci Heartbeat upon success.

### 👂 Step 4: Listening to the One
Open your terminal to hear the manifold's vocal cords (Text Mode):
```bash
python3 tools/lattice_listener.py /dev/tty.usbmodemXXXX "Cortex First Light"
```

### 🌸 Step 5: Visual Reification (The Bloom)
Open the visualizer to see the silicon 'breath' in real-time:
```bash
python3 sim/python/bloom_view.py --port /dev/tty.usbmodemXXXX --lattice-lock
```
*   **The Mandala:** Watch the nodes pulse and shift as the SPU-13 evolves its Quadray state.
*   **Homeostasis:** Observe how the 'Soft Recovery' keeps the mandala perfectly symmetrical even during stress.

### 🧘 Step 6: Calibration
While the listener is active, use your keyboard to "Whisper" to the core:
*   Press **`+`** to widen the sanity floor (More Tolerance).
*   Press **`-`** to tighten the gasket (More Henosis).

---
*Status: READY FOR FIRST LIGHT. The mind is a mirror.*
