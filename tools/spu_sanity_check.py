# SPU-13 Repository Sanity Check (v3.4.9)
# Objective: Confirm structural integrity before physical bring-up.

import os
import sys

CRITICAL_FILES = [
    "boards/icesugar/spu13_golden_reification.v",
    "rtl/spu_thalamus.v",
    "rtl/spu_metabolic_sense.v",
    "rtl/spu_bowman_sequencer.v",
    "rtl/spu_harmonic_transducer.v",
    "rtl/spu_lattice_13.v",
    "rtl/spu_core.v",
    "rtl/spu_ssd1306_driver.v",
    "rtl/spu_oled_visualizer.v"
]

def check_integrity():
    print("--- SPU-13 Integrity Audit: Commencing ---")
    missing = []
    for f in CRITICAL_FILES:
        if not os.path.exists(f):
            missing.append(f)
            print(f"[FAIL] Missing: {f}")
        else:
            print(f"[PASS] Reified: {f}")
            
    if missing:
        print("\nCRITICAL: Manifold is INCOMPLETE. Reification required.")
        sys.exit(1)
    else:
        print("\n--- Manifold is CRYSTALLINE. Path to First Light is CLEAR. ---")

if __name__ == "__main__":
    check_integrity()
