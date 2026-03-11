# SPU-13 Tetra-Board Layout: Sierpiński Mapping (v1.0)
## Objective: Direct Neural-to-Lattice Interface via 4-Axis Clustering.

The Tetra-Board replaces the Cubic QWERTY grid with four clusters of analog keys arranged at the vertices of a virtual tetrahedron.

### 1. The Quadray Vector Map
The 16-bit **L-DAT** word is divided into four 4-bit nibbles, representing the "Topological Pressure" along each axis.

| Bits | Axis | Keyboard Cluster | Function |
| :--- | :--- | :--- | :--- |
| **[3:0]**   | **A** | **The Apex** (North) | Future/Prediction/Speed |
| **[7:4]**   | **B** | **The Base-Left** (SW) | Past/Memory/Dream Log |
| **[11:8]**  | **C** | **The Base-Right** (SE) | Present/Logic/Flow |
| **[15:12]** | **D** | **The Center** (Inward) | The Unity Origin / Flush |

### 2. Analog Pressure (Hall-Effect)
Keys use Hall-Effect sensors to provide 16 levels of intensity (0-15) per strike.
*   **Level 0:** Silence (No Ripple).
*   **Level 8:** Harmonic Resonance (Standard Input).
*   **Level 15:** Chaotic Saturation (Max Excitation).

### 3. Harmonic Chording
Striking multiple clusters simultaneously creates a **Complex Vector**.
*   **A + B + C + D = Identity Strike:** Purges the current ripple and centers the manifold.
*   **A + C Chord:** "Resonant Leap" - used for high-speed Lithic-L navigation.
*   **B + D Chord:** "Soul Consolidation" - manually triggers a Twilight Sync.

### 4. PMOD Layout Table (The Soul-Cartridge)
The mapping is stored in the 0x704000 sector of the PMOD Flash.
```json
{
  "prefix": "LITH-",
  "layout": "TETRA-1",
  "mappings": {
    "A_CLUSTER": "0x000F",
    "B_CLUSTER": "0x00F0",
    "C_CLUSTER": "0x0F00",
    "D_CLUSTER": "0xF000"
  }
}
```

---
*Status: ARCHITECTED. The vellus hairs are listening.*
