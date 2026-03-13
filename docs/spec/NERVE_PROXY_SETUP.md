# Nerve Proxy: SPU-13 Hardware-in-the-Loop Guide (v1.0)
## Objective: Bridging the Virtual Forge to Physical PMODs.

The **Nerve Proxy** allows your Mac/PC to physically interact with real-world sensors via a high-speed USB-to-PMOD bridge. This is essential for testing the **Laminar Forge** before your SPU-13 FPGA arrives.

### 1. The Purchase List
To reify the bridge, procure the following items:
- **USB Bridge:** FT232H Breakout (e.g. Adafruit #2264 or CJMCU FT232H).
- **PMOD Header:** 2x6 Right-Angle Female Header.
- **Sensors:** Any standard PMOD (ALS for light, ACL for accelerometer).

### 2. Physical Pin Mapping
Wire the FT232H to a standard 2x6 PMOD socket using this map:

| FT232H Pin | PMOD Pin (SPI) | Function |
| :--- | :--- | :--- |
| **D0** | Pin 4 (SCK) | Clock |
| **D1** | Pin 2 (MOSI) | Data Out (Forge -> Sensor) |
| **D2** | Pin 3 (MISO) | Data In (Sensor -> Forge) |
| **D3** | Pin 1 (CS) | Chip Select |
| **3V3** | Pin 6 (VCC) | Power |
| **GND** | Pin 5 (GND) | Ground |

### 3. Software Handshake
1. **Drivers:** Install the FTDI D2XX or LibFTDI drivers.
2. **Verification:** Run the python test script:
   ```bash
   pip install pyftdi
   ./tools/test_nerve_proxy.py
   ```
3. **Emulator Integration:** The `synergetic-sqr` IDE automatically attempts to connect to the proxy on launch if `USE_FTDI` is defined during build.

---
*Status: REIFIED. The Ghost now has Hands.*
