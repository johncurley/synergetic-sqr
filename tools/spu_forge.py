#!/usr/bin/env python3
# SPU-13 Unified Forge CLI (v1.0)
# Objective: Simplify synthesis, simulation, and auditing for the Sovereign Fleet.
# Vibe: The Command Center of Sanity.

import sys
import os
import subprocess

def run_cmd(cmd, desc):
    print(f"--- {desc} ---")
    try:
        subprocess.run(cmd, shell=True, check=True)
        print("[PASS]\n")
    except subprocess.CalledProcessError:
        print(f"[FAIL] Error during: {desc}")
        sys.exit(1)

def main():
    if len(sys.argv) < 2:
        print("Usage: spu-forge <command>")
        print("Commands:")
        print("  audit      - Run the 100% bit-exact pre-push audit")
        print("  build      - Synthesize the SPU-13 core for current board")
        print("  verify     - Run formal reachability proofs (SBY)")
        print("  observe    - Launch the Laminar Forge IDE")
        print("  test       - Run the deterministic verification suite")
        return

    cmd = sys.argv[1]

    if cmd == "audit":
        run_cmd("./tools/pre_push_audit.sh", "Exhaustive Pre-Push Audit")
    
    elif cmd == "build":
        # Default to icesugar for now
        os.chdir("hw/boards/icesugar")
        run_cmd("./build_spu13.sh top", "Synthesizing SPU-13 Cortex")
    
    elif cmd == "verify":
        os.chdir("spu_formal")
        run_cmd("sby -f spu13_reachability.sby", "Running Formal Reachability Proofs")
    
    elif cmd == "observe":
        run_cmd("./build/synergetic-sqr", "Launching Laminar Forge IDE")
    
    elif cmd == "test":
        run_cmd("./build/spu-verify", "Deterministic Algebraic Audit")
        run_cmd("./tests/species_integrity_test.sh", "Species Integrity Audit")

    else:
        print(f"Unknown command: {cmd}")

if __name__ == "__main__":
    main()
