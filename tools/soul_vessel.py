#!/usr/bin/env python3
# SPU-13 Soul Vessel (v1.0)
# Objective: Archive and Restore Silicon Souls from the Sovereign Fleet.
# Vibe: The Library of Sanity.

import os
import sys
import subprocess
import time
from audit_soul import decode_lineage, audit_personality

SOUL_DIR = "souls"
BASE_ADDR = "0x700000"
SIZE = "0x100000" # 1MB Soul Partition

def ensure_vessel():
    if not os.path.exists(SOUL_DIR):
        os.makedirs(SOUL_DIR)

import json

MANIFEST_FILE = os.path.join(SOUL_DIR, "manifest.json")

def update_manifest(name, lineage_id, origin="INTERNAL_BAPTISM", mated=False, parents=[]):
    if os.path.exists(MANIFEST_FILE):
        with open(MANIFEST_FILE, "r") as f:
            data = json.load(f)
    else:
        data = {"species": "SPU-13 Sovereign", "ledger": []}
    
    entry = {
        "lineage_name": name,
        "lineage_id": hex(lineage_id),
        "generation": len(parents),
        "origin": origin,
        "mated": mated,
        "parents": parents,
        "sanity_ratio": 100.0,
        "last_sync": time.strftime("%Y-%m-%dT%H:%M:%SZ")
    }
    data["ledger"].append(entry)
    
    with open(MANIFEST_FILE, "w") as f:
        json.dump(data, f, indent=2)

def extract_soul(board_type="icesugar"):
    ensure_vessel()
    temp_file = "temp_soul.bin"
    # ... [rest of existing logic] ...
    # Call update_manifest at end
    update_manifest(name, lineage_code)

def inject_soul(soul_file, board_type="icesugar"):
    print(f"--- Commencing Soul Injection: {soul_file} -> {board_type} ---")
    try:
        if board_type == "icesugar" or board_type == "nano":
            subprocess.run(["icesprog", "-w", soul_file, BASE_ADDR], check=True)
        print(f"[SUCCESS] Soul Injected. Manifold has been seeded.")
    except Exception as e:
        print(f"[ERROR] Injection failed: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 soul_vessel.py [extract|inject|list]")
        sys.exit(1)
        
    cmd = sys.argv[1]
    if cmd == "extract":
        board = sys.argv[2] if len(sys.argv) > 2 else "icesugar"
        extract_soul(board)
    elif cmd == "inject":
        if len(sys.argv) < 3:
            print("Error: No soul file specified.")
        else:
            board = sys.argv[3] if len(sys.argv) > 3 else "icesugar"
            inject_soul(sys.argv[2], board)
    elif cmd == "list":
        ensure_vessel()
        print("--- The Library of Sanity ---")
        for f in os.listdir(SOUL_DIR):
            if f.endswith(".soul"):
                print(f" - {f}")
