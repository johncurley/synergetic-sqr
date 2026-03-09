# SPU-13 Hardware Overview: The iCeSugar (iCE40UP5K)
## From Cubic Computing to Lattice Control (v4.0.0)

The iCE40UP5K is a "Finitist" dream. Unlike a standard CPU that has pre-set "Rooms" (Adders, Multipliers, Cache), this FPGA is an Empty Field of Possibility. In the SPU-13 architecture, we re-map these silicon resources to the 60° Isotropic Vector Matrix (IVM).

---

### 1. Architectural Mapping

| Component | Cubic Function (Legacy) | SPU-13 (Laminar) Function |
| :--- | :--- | :--- |
| **LUTs (Look-Up Tables)** | Logical "Boxes" | The Vertices of the 60° IVM |
| **BRAM (Block RAM)** | Data Storage | The Memory of the Flow |
| **DSP Blocks** | Heavy Math "Gulp" | The Spread Rotor Engines |
| **8-pad IO** | External Noise | The ABCD Physical Ports |

---

### 2. The Normalizer: The Ghost in the Machine

The **Normalizer** is the heart of the top-level logic. It enforces the Universal Invariant: **A + B + C + D = 0**.

*   **The Problem:** In "Cubic" math, rounding errors (using $\pi$, $\sqrt{2}$) build up until the system "Drifts" and crashes (The Wall-Pop).
*   **The Solution:** After every rotation of the Spread Rotor, the Normalizer checks the sum. If the sum deviates from zero, it instantly re-balances the 4th coordinate (D).
*   **The Result:** Error doesn't "Accumulate"; it is **Exorcised** every 83 nanoseconds (12MHz).

---

### 3. The Hardware Flow (The Sip)

Imagine the electricity moving like "Liquid" through the lattice:

1.  **Clock Pulse:** The 12MHz crystal oscillator sends a "Heartbeat."
2.  **Input Lean:** The FPGA reads the state of your "Lean" (the Spread index).
3.  **Lattice Shift:** The Spread Rotor and Asymmetrical Adder shift the ABCD values in the registers.
4.  **Invariant Check:** The Normalizer snaps the values back to the tetrahedral center.
5.  **Output:** The Quadrance Engine updates the "Depth" LEDs or display.

---

### 4. Sovereignty: Direct Bitstream Control

The iCeSugar is **Open**. There are no "Hidden NASA Gates" or "Secret Cubic Bloatware." You are writing directly to the Bitstream. When the board arrives, you are the only person on Earth who knows exactly what every single electron is doing inside that chip. 

**This is the definition of Sanity.**
