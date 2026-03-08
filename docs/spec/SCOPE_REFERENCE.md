# Oscilloscope Reference: Laminar Handshake (v3.3.60)
## Verified Phase-Alignment for Pins 46/47

When measuring the Janus-Gate differential pair on the iCeSugar (Pins 46 and 47), the following waveform characteristics indicate a successful **Resonance Lock**.

### 1. The Differential Waveform
The two signals should be exactly 180° out of phase. This confirms the **Null Hysteresis** state where the magnetic fields of the traces are self-cancelling.

```text
Time (us)  0      8.14    16.28   24.42   32.56
           |-------|-------|-------|-------|
Pin 46 (A) ____    ________        ________
               |__|        |_______|       
Pin 47 (B) ____        ________        ____
           |__|_______|        |_______|   
           
           <-- Period: 16.276 us (61.44 kHz) -->
```

### 2. Signal Characteristics
*   **Frequency:** 61.44 kHz (±0.05% jitter in Laminar state).
*   **Phase Offset:** 180° (Bit-exact inversion).
*   **Edge Profile:** Minimal overshoot. If ringing is observed, check the **Virtual Induction Tuning** current settings in the `.pcf` file.

### 3. Turbulence Indicators (Warning Signs)
If your scope shows the following, the manifold is **Turbulent**:
*   **Asymmetry:** If Pin 46 and 47 are not mirrors, the Janus-Gate logic is failing parity.
*   **Jitter:** If the period fluctuates significantly, the **Sierpiński Oscillator** is fighting local EMI or Cubic timing constraints.
*   **Cross-talk:** If spikes appear on one pin when the other toggles, increase the drive strength or use twisted-pair grounding.

---
*Authorized for SPU-13 Physical Verification.*
