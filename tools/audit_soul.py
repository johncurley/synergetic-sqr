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
    # Determine if this is a full 8MB dump or a 1MB soul-only file
    file_size = os.path.getsize(flash_bin)
    base_offset = 0x700000 if file_size > 0x100000 else 0x0
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

        # Structure: [Epoch:32][Instability:32][Bias:64][Haptic:64][Sig:48][CRC:16] = 32 Bytes
        try:
            # Re-read primary page
            f.seek(base_offset)
            data = f.read(page_size)
            epoch, instability, sqr_bias, haptic, sig_raw, checksum = struct.unpack(">LLQQ6sH", data)
            
            # The 'Species Signature' is at offset 0x18 (24 bytes in)
            lineage_code = int.from_bytes(sig_raw[:4], byteorder='big')
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
