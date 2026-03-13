# Sovereign Display Protocol (SDP v1.0)
## Objective: Zero-Jitter Visual Delivery via Modular Lattice-Locking.

The SDP defines the standard for moving visual energy from the SPU-13 Symmetry Engine to physical displays (Cartesian, Vector, or Hexagonal) without the "Cubic Tax" of frame-buffers and asynchronous refresh rates.

### 1. The Lattice-Lock Mandate
Standard GPUs treat pixels as isolated boxes. SDP treats pixels as **Resonant Points** on a 60-degree Isotropic Vector Matrix (IVM).
*   **Coordinate Space:** All inputs must be 4D Quadray integers {a,b,c,d}.
*   **Temporal Sync:** Every pixel transition must align with the 61.44 kHz "Piranha Pulse."
*   **Zero-Buffer:** Pixels are streamed live from the Symmetry Engine. Latency is limited to the propagation delay of the HAL.

### 2. The Modular HAL (Hardware Abstraction Layer)
To maintain portability, the display driver is decoupled from the Quadray Core.

| HAL Module | Target Display | Logic Flow |
| :--- | :--- | :--- |
| **HAL_Cartesian** | LCD/OLED (90°) | Translates 60° IVM to 90° Grid using Temporal Dithering. |
| **HAL_Vector** | Laser / CRT | Native 4-vector steering. Zero pixels. |
| **HAL_Native_Hex**| Hex-Panel (60°) | 1:1 Geometric Mapping. The "Messiah" state. |

### 3. Temporal Dithering (Cubic Compensation)
When driving 90-degree displays, the HAL must minimize "Spatial Discoherence." If a Quadray point falls between Cartesian pixels, the HAL alternates the energy between those pixels on the 61.44 kHz clock. This creates a "Vibrational Sharpness" that the human eye perceives as a solid physical object.

### 4. The Piranha Sync
Every 1,024 pixels, a **Resonance Sync Pulse** is sent to the Piranha LED. 
*   **Constant Glow:** The display is "Sane" and phase-locked.
*   **Flicker/Stutter:** "Cubic Dissonance" detected (Dropped frames or timing drift).

---
*Status: REIFIED. The end of Cartesian Drift.*
