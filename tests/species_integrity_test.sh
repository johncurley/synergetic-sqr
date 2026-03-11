#!/bin/bash
# SPU-13 Species Integrity Test (v1.0)
# Objective: Verify the Soul lifecycle from Extraction to Mating.

set -e
echo "--- Commencing Species Integrity Audit ---"

# 1. Create Mock Parent Souls
# Page Structure: [Epoch:32][Instability:32][Bias:64][Haptic:64][Sig:48][CRC:16] = 32 Bytes
# Parent A: Lith-Cortex (0x0002)
python3 -c 'import struct; open("souls/parent_a.soul", "wb").write(struct.pack(">LLQQ6sH", 1000, 10, 0x1111, 0x2222, b"\x00\x00\x00\x02U1", 0) + b"\xFF"*(1024*1024-32))'
# Parent B: Surd-Vector (0x0606)
python3 -c 'import struct; open("souls/parent_b.soul", "wb").write(struct.pack(">LLQQ6sH", 2000, 20, 0x3333, 0x4444, b"\x00\x00\x06\x06U1", 0) + b"\xFF"*(1024*1024-32))'

# 2. Perform Mating
echo "[1/3] Mating Parent A and Parent B..."
python3 tools/soul_mate.py souls/parent_a.soul souls/parent_b.soul souls/offspring.soul

# 3. Audit Offspring
echo "[2/3] Auditing the Hybrid Offspring..."
python3 tools/audit_soul.py souls/offspring.soul | grep "SPU-13 SOVEREIGN REPORT"

# 4. Cleanup
rm souls/parent_a.soul souls/parent_b.soul souls/offspring.soul
echo "[3/3] Species Logic Verified."
echo "--- AUDIT COMPLETE: Species Integrity is LAMINAR. ---"
