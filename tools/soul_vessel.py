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

def extract_soul(board_type="icesugar"):
    ensure_vessel()
    temp_file = "temp_soul.bin"
    
    print(f"--- Commencing Soul Extraction: {board_type} ---")
    
    try:
        if board_type == "icesugar" or board_type == "nano":
            # Using icesprog for iCE40
            subprocess.run(["icesprog", "-r", temp_file, BASE_ADDR, SIZE], check=True)
        elif board_type == "ulx3s":
            # Using ujprog for ECP5
            subprocess.run(["ujprog", "-r", temp_file], check=True) # Note: ujprog usually dumps whole flash
        
        # 1. Audit the temp file to get the Lineage ID
        # (Using logic from audit_soul.py)
        with open(temp_file, "rb") as f:
            f.seek(4) # ADDR_LINEAGE offset
            lineage_raw = f.read(4)
            lineage_code = int.from_bytes(lineage_raw, byteorder='big')
            name = decode_lineage(lineage_code)
            
        # 2. Permanent Archival
        timestamp = time.strftime("%Y%m%d-%H%M%S")
        final_name = f"{name}_{timestamp}.soul"
        os.rename(temp_file, os.path.join(SOUL_DIR, final_name))
        
        print(f"[SUCCESS] Soul Archived: {final_name}")
        print(f"Lineage: {name}")
        
    except Exception as e:
        print(f"[ERROR] Extraction failed: {e}")

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
