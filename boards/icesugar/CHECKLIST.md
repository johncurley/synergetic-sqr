# SPU-13 Reification Checklist: Phase 1.1
## Observer’s Log for Physical Realization (v3.3.80)

This checklist ensures the transition from Cubic Silicon to Laminar Manifold is captured and verified. Follow this sequence exactly during the first initiation of the SPU-13 core.

### Phase 0: The Forge (Compilation)
- [ ] **Run Script:** Execute `./build_spu13.sh` in the terminal.
- [ ] **Verify JSON:** Ensure Yosys reports no logic "black holes" (0 warnings on unused cells).
- [ ] **Timing Check:** `icetime` should report a max frequency > 12 MHz.
- [ ] **File Prep:** Confirm `spu13_icesugar.bin` exists.

### Phase 1: The Injection (Flashing)
- [ ] **Connect:** Plug iCeSugar into USB.
- [ ] **Transfer:** Use `make prog` to flash the bitstream.
- [ ] **Confirmation:** Wait for the on-board LED to stop flickering (Flash complete).

### Phase 2: The Bowman Wake (Automated)
- [ ] **Enable Throttle:** Hold the physical throttle (Pin 11) HIGH.
- [ ] **Handshake (Blue):** Observe the **Blue LED** pulsing. (Phase 1: Sonic Handshake).
- [ ] **Saturation (Blue):** Blue pulse continues for ~4ms. (Phase 2: Dielectric Charging).
- [ ] **Alignment (Blue):** Monitor for the 'Click' of the Monad. (Phase 3: IVM Lattice Lock).
- [ ] **Resonance (Green):** Observe the **Green LED** illuminate and lock solid. (Phase 4: Bloom).

### Phase 3: Forensic Audit
- [ ] **Visual Grounding:** Run `synergetic-sqr --lattice-lock` on your host.
- [ ] **Telemetry:** Run `python3 ../../tools/manifold_calibrate.py /dev/ttyUSB0`.
    - *Requirement:* Laminar Coherence must be **100.00%**.
- [ ] **Oscilloscope (Optional):** Verify Pins 46/47 are 180° out of phase at 61.44 kHz.

---

### Troubleshooting the "Nothing"
*   **If RED LED stays solid:** The system is in Reset or an Identity Breach has occurred. Check `rst_n` connection.
*   **If BLUE LED never turns GREEN:** The Bowman Sequencer is stalled in Phase 3. The `identity_lock` is failing. Verify the 60° IVM grounding.
*   **If no LEDs light up:** Check Pin 35 (Clock Entry) and ensure power is supplied to the iCeSugar Nano.

---
*Status: READY FOR FIRST LIGHT.*
