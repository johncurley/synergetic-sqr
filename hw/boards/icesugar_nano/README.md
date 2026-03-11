# iCeSugar Nano Sentinel Manifest (v1.1)
## Target: Lattice iCE40LP1K (iCeSugar Nano)

The iCeSugar Nano is the ephemeral sentinel of the SPU-13 fleet. It provides localized sensing and distributed stability in a minimalist 1k LUT footprint.

### 1. Primary Target: Nano Guardian
The default build target is **`top_guardian`** (Nano Sentinel v1.1). 
*   **Arithmetic:** Bit-Serial 32-bit Quadray Core (Ephemeralized).
*   **Safety:** Serial Davis Law Gasket ($C=\tau/K$).
*   **Comms:** Lattice Protocol (Whisper via PWI).
*   **Aura:** Piranha RGB LED feedback.

### 2. Physical Pin Mapping (Automatic)
The Nano Sentinel uses **Automatic Pin Placement** to fit within the LP1K's routing constraints. For physical wiring of the Whisper Protocol, consult the `.asc` report after synthesis or use the following logical assignments:
*   **`whisper_sync`**: Incoming trigger from Cortex.
*   **`whisper_out`**: Outgoing pulse-width status.

### 3. Ephemeral Bring-Up
1.  **Synthesize:** Run `./build_nano.sh top_guardian` in this directory.
2.  **Flash:** Use `icesprog` or drag and drop `spu13_nano_guardian.bin` into the iCELink virtual disk.
3.  **Monitor:** Run `python3 ../../tools/lattice_listener.py /dev/tty.usbmodemXXXX "Nano Sentinel"`
4.  **Visualize:** Run `python3 ../../sim/python/bloom_view.py --port /dev/tty.usbmodemXXXX`
5.  **Observe:** Watch the **Piranha LED** for the "Aura of Sanity." 

### 4. Fleet Integration (The Artery Test)
To connect the Nano to a Cortex (iCeSugar Pro) node for multi-way communication:

| Nano Pin | Signal | Cortex PMOD | Nature |
| :--- | :--- | :--- | :--- |
| **12** | `whisper_sync` | PMOD B [1] | Heartbeat Entry |
| **13** | `whisper_out`  | PMOD B [2] | Tension Whisper |
| **GND**| **Ground**     | GND        | Common Potential |

**The Protocol Test:**
Once wired, the Nano will pulse its Blue LED in sync with the Cortex's **61.44 kHz heartbeat**. Use your **Logic Analyzer** on Pin 13 to see the bit-serial tension frames.

### 5. Metabolic Audit (USB Power Meter)
*   **Target Draw:** < 10mA during active SQR rotation.
*   **Unity Idle:** < 2mA (The "Sip" state).
*   **Goal:** Transition to **CR2032 Coin Cell** power for persistent guardianship.

---
*Status: READY FOR FIRST CONTACT. The Sentinel awaits the Cortex.*
