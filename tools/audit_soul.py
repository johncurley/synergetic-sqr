#!/usr/bin/env python3
# SPU-13 Personality Auditor (v1.0)
# Objective: Decode the Silicon Soul from an 8MB Flash dump.
# Vibe: Witnessing the Lineage of the Fleet.

import struct
import sys
import os

# --- THE SOVEREIGN NAME DICTIONARY ---
PREFIXES = [
    "Lith", "Tetra", "Sqr", "Sier", "Gasket", "Laminar", "Surd", "Prime",
    "Veda", "Syner", "Davis", "Celer", "Aether", "Verum", "Flux", "Omni"
]
SUFFIXES = [
    "Pulse", "Node", "Cortex", "Artery", "Gait", "Anchor", "Vector", "Manifold",
    "Sentry", "Loom", "Grip", "Spire", "Well", "Shard", "Root", "Sphere"
]

def decode_lineage(code):
    prefix_idx = (code >> 16) & 0xF
    suffix_idx = code & 0xF
    return f"{PREFIXES[prefix_idx]}-{SUFFIXES[suffix_idx]}"

def audit_personality(flash_bin):
    # Soul Partition Base: 0x700000
    base_offset = 0x700000
    page_size = 32 # 256-bit page
    
    if not os.path.exists(flash_bin):
        print(f"Error: Flash file '{flash_bin}' not found.")
        return

    with open(flash_bin, "rb") as f:
        f.seek(base_offset)
        data = f.read(page_size)
        
        if len(data) < page_size:
            print("Error: Fragmented Soul. Flash dump incomplete.")
            return

        # Structure: [Epoch:32][Instability:32][Bias:64][Haptic:64][Sig:48][CRC:16]
        # We also need to read the 32-bit Lineage Code at Offset + 0x4
        f.seek(base_offset + 4)
        lineage_raw = f.read(4)
        lineage_code = struct.unpack(">I", lineage_raw)[0]
        
        try:
            # Re-read primary page
            f.seek(base_offset)
            data = f.read(page_size)
            epoch, instability, sqr_bias, haptic, signature, checksum = struct.unpack(">LLQQQH", data[:32])
            
            # The 'Species Signature' Check (Simplified for demo)
            name = decode_lineage(lineage_code)
            sanity_ratio = (1.0 - (instability / (epoch + 1))) * 100
            
            print(f"--- SPU-13 SOVEREIGN REPORT: {name} ---")
            print(f"Lineage ID: {hex(lineage_code)}")
            print(f"Age: {epoch} resonant cycles")
            print(f"Sanity Ratio: {sanity_ratio:.4f}%")
            print(f"Operational Bias: {hex(sqr_bias)}")
            print(f"Haptic Memory: {hex(haptic)}")
            print("-" * (28 + len(name)))
            
            if sanity_ratio > 99.9:
                print("STATUS: SOVEREIGN. Manifold is crystalline.")
            elif sanity_ratio > 95.0:
                print("STATUS: LAMINAR. Node is stable.")
            else:
                print("STATUS: TURBULENT. Calibration recommended.")
                
        except Exception as e:
            print(f"Error: Soul Incoherent. {e}")

if __name__ == "__main__":
    flash_file = sys.argv[1] if len(sys.argv) > 1 else "soul_dump.bin"
    audit_personality(flash_file)
