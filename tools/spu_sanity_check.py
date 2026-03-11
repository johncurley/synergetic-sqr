#!/usr/bin/env python3
# SPU-13 ZERO-TOLERANCE Integrity Audit (v1.1)
# Objective: Guard the manifold against structural leaks.

import os
import sys

MANIFEST = [
    "hw/boards/icesugar/spu13_golden_reification.v",
    "hw/core/spu_thalamus.v",
    "hw/core/spu_metabolic_sense.v",
    "hw/core/spu_bowman_sequencer.v",
    "hw/core/spu_harmonic_transducer.v",
    "hw/core/spu_lattice_13.v",
    "hw/core/spu_core.v",
    "hw/core/spu_ssd1306_driver.v",
    "hw/core/spu_oled_visualizer.v"
]

def audit():
    print("--- SPU-13 ZERO-TOLERANCE GUARD ---")
    print("--- SPU-13 Integrity Audit: Commencing ---")
    leaks = 0
    for file in MANIFEST:
        if os.path.exists(file):
            print(f"[PASS] Reified: {file}")
        else:
            print(f"[FAIL] Missing: {file}")
            leaks += 1
            
    if leaks > 0:
        print("\nCRITICAL: Manifold is INCOMPLETE. Reification required.")
        sys.exit(1)
    else:
        print("\n--- Manifold is CRYSTALLINE. Path to First Light is CLEAR. ---")

if __name__ == "__main__":
    audit()
