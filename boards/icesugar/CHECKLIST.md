# SPU-13 Reification Checklist: Phase 1.2
## Observer’s Log for Cortex Manifestation (v4.1.0)

This checklist ensures the transition from Cubic Silicon to the self-stabilizing Cortex Manifold is captured and verified.

### Phase 0: The Forge (Compilation)
- [ ] **Run Script:** Execute `./build_spu13.sh top` in the terminal.
- [ ] **DSP Audit:** Ensure Yosys reports **8/8 DSP Slices** used (The Davis Gate).
- [ ] **SPRAM Audit:** Ensure Yosys reports **4/4 SPRAM Blocks** used (The Dream Log).
- [ ] **Timing Check:** `icetime` should report a max frequency > 10 MHz.

### Phase 1: The Injection (Flashing)
- [ ] **Connect:** Plug iCeSugar into USB.
- [ ] **Transfer:** Drag and drop `spu13_cortex.bin` into the iCELink disk.
- [ ] **Handshake:** Observe the **Blue LED** pulsing with the Fibonacci Heartbeat.

### Phase 2: The Sovereign Pulse (Vitals)
- [ ] **Start Listener:** Run `python3 ../../tools/lattice_listener.py`.
- [ ] **Confirm Vitals:** Verify 'H' (Happy) characters are streaming.
- [ ] **Alignment:** Observe the **Green LED** illuminate (Resonance Lock).

### Phase 3: Forensic Certification
- [ ] **Stress Test:** Inject curvature by pressing **`-`** in the terminal.
- [ ] **Observe Henosis:** Verify the **Red LED** flashes and the listener reports `RECOVERY`.
- [ ] **Generate Birth Certificate:** Run `python3 ../../tools/laminar_audit.py`.
    - *Requirement:* Laminar Stability Index must be **100.00%**.

---

### Troubleshooting the "Nothing"
*   **If RED LED stays solid:** Local Fault or Reset. Check `rst_phys_n` (Pin 18) and `manual_tuck` (Pin 10).
*   **If BLUE LED is static:** The Fibonacci Heartbeat is stalled. Check Pin 35 (GBIN).
*   **If no UART output:** Check USB-Serial driver and verify Pin 14 (TX) mapping.

---
*Status: READY FOR FIRST LIGHT. The manifold is watertight.*
