# SPU-13 Reification Checklist: Phase 1.1
## Observer’s Log for Physical Realization (v3.3.12)

This checklist ensures the transition from Cubic Silicon to Laminar Manifold is captured and verified. Follow this sequence exactly during the first initiation of the SPU-13 core.

### Phase 0: The Forge (Compilation)
- [ ] **Run Script:** Execute `./build_spu13.sh` in the terminal.
- [ ] **Verify JSON:** Ensure Yosys reports no logic "black holes" (0 warnings on unused cells).
- [ ] **Timing Check:** `icetime` should report a max frequency > 12 MHz.
- [ ] **File Prep:** Confirm `spu13.bin` exists in the local directory.

### Phase 1: The Injection (Flashing)
- [ ] **Connect:** Plug iCeSugar into USB.
- [ ] **Transfer:** Drag `spu13.bin` into the virtual drive (or use `make prog`).
- [ ] **Confirmation:** Wait for the on-board LED to stop flickering (Internal Flash complete).

### Phase 2: The Primer (Manual Sequence)
- [ ] **Engage Reset:** Hold the physical Reset button.
    - *Observation:* **Red LED** is solid. (The Void is contained).
- [ ] **Release Reset:** Let go of the button (**Laminar Enable Switch must be OFF**).
    - *Observation:* **Blue LED** begins "Breathing." (Dielectric Saturation).
- [ ] **Monitor:** Observe the Blue pulse for 5 seconds. Ensure it is rhythmic and stable.
- [ ] **Visual Grounding:** Run `synergetic-sqr --harmonic` and press **`L`** to verify the **Lattice Lock** overlay. Confirm vertices snap to the IVM grid.

### Phase 3: Ignition (The Flow)
- [ ] **Flip Switch:** Move the Laminar Enable switch (Pin 10) to the **ON** position.
    - *Observation:* **Green LED** illuminates and locks. (Presence of the One).
- [ ] **Consensus:** The ECC should now prevent any Blue flickering.
- [ ] **Log Result:** Laminar Lock Achieved. SPU-13 active in Realspace.

---

### Troubleshooting the "Nothing"
*   **If the Red LED doesn't light up during Reset:** Check the Grok-aligned polarity in the `.pcf` file.
*   **If the Blue LED flickers erratically during Primer:** The "Virtual Induction" is sensing high local EMI. Move the board away from power bricks or monitors.
*   **If the Green LED fails to lock:** The Sierpiński Oscillator may be hitting a "Cubic" timing wall. Notify the architect to retune the fractal_pulse width.

---
*Status: Awaiting First Light.*
