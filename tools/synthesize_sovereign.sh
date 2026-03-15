#!/bin/bash
# SPU-13 Unified Sovereign Synthesis (v1.5)
# Objective: Generate Bit-Exact Sovereign Bitstreams for all major targets.

echo "--- SPU-13 Sovereign Fleet Synthesis Commencing ---"

# 1. iCEsugar (iCE40UP5K)
echo "[TARGET] iCEsugar (UP5K)"
cd hw/boards/icesugar
make -f Makefile_sovereign clean all
cd ../../..

# 2. Tang Nano 20K (Gowin GW2AR-18)
echo "[TARGET] Tang Nano 20K"
cd hw/boards/tang_nano_20k
./build_sovereign.sh
cd ../../..

# 3. ULX3S (ECP5-85F)
echo "[TARGET] ULX3S (ECP5)"
cd hw/boards/ulx3s
./build_sovereign.sh
cd ../../..

echo "--- Sovereign Fleet Synthesis Complete ---"
