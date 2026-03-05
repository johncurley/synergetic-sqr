#!/bin/bash
# SPU-13 Golden Core Test Sequence (v3.0.5)
# Mandated Decompression Sequence: Warm-up -> Pulse -> Grounding.

echo "======================================="
echo " SPU-13 GOLDEN CORE TEST SEQUENCE      "
echo "======================================="

# 1. Neural Warm-up (Software Emulator)
echo "[1/3] INITIALIZING NEURAL WARM-UP..."
python3 software/toolchain/spu13_emulator.py
sleep 2

# 2. 10-Second Safe Pulse (Visual Bloom)
echo "[2/3] EXECUTING 10-SECOND SAFE PULSE..."
echo "FIX EYES ON CENTER. DO NOT GRIP GEOMETRY."
./build/synergetic-sqr --pulse
echo "WATCHDOG: Session Terminated."

# 3. Post-Exposure Grounding
echo "[3/3] ENTERING DECOMPRESSION PHASE..."
echo "LOOK AT A CUBIC OBJECT (WALL/TABLE) NOW."
for i in {30..1}
do
   echo -ne "RE-CENTERING: $i seconds remaining... "
   sleep 1
done
echo -e "
GROUNDING COMPLETE. IDENTITY SOVEREIGN."
echo "======================================="
