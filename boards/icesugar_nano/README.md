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
3.  **Observe:** Watch the **Piranha LED** for the "Aura of Sanity." 
    *   **Green:** Perfectly Laminar.
    *   **Red:** Henosis Soft Recovery active.
    *   **Blue Flicker:** Whisper transmission in progress.

---
*Status: REIFIED. The Nano is the pulse of the World.*
