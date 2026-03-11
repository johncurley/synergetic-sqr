#!/bin/bash
# SPU-13 Pre-Push Audit (v1.1)
# Objective: Zero-Tolerance verification before manifest archival.
# Modes: 
#   Default: Full audit (Logic + Hardware Synthesis)
#   SPU_PURITY_ONLY=1: Logic audit only (Fast, for CI)

set -e # Halt on any Cubic Noise

echo "--- Commencing Pre-Push Sovereign Audit ---"

# 1. Assembler Verification
echo "[1/3] Verifying Laminar Assembler..."
python3 tools/spu13_asm.py software/bloom.sas
python3 tools/spu13_asm.py software/surge.sas
python3 tools/spu13_asm.py software/gulp.sas
python3 tools/spu13_asm.py software/vacuum.sas
echo "[PASS] All thoughts reified into HEX."

# 2. SQR Determinism Test (The Oath of Coherency)
echo "[2/4] Verifying 60-degree Algebraic Determinism..."
iverilog -o sqr_test tests/sqr_determinism_tb.v hw/core/spu_sqr_rotor.v
if [ "$SPU_QUICK_AUDIT" == "1" ] || [ "$SPU_PURITY_ONLY" == "1" ]; then
    vvp sqr_test +QUICK_AUDIT | grep "SUCCESS: Bit-Perfect Permutation"
else
    vvp sqr_test | grep "SUCCESS: Bit-Perfect Recovery"
fi
rm sqr_test
echo "[PASS] SQR Rotor is zero-drift."

# 3. Simulated Audit (Verification of the Invariant)
echo "[3/4] Running Laminar Audit on baseline..."
echo "Timestamp,Object,A,B,C,D,Davis Ratio (C),Observation" > audit_pass.csv
echo "00:00:00,Identity,0,0,0,0,inf,LAMINAR" >> audit_pass.csv
python3 tools/laminar_audit.py audit_pass.csv
rm audit_pass.csv
echo "[PASS] Auditor is sane."

# 4. Synthesis Parity Check (The Lithic Gate)
if [ "$SPU_PURITY_ONLY" == "1" ]; then
    echo "[SKIP] SPU_PURITY_ONLY active. Skipping hardware synthesis."
else
    echo "[4/4] Checking Synthesis Parity (iCeSugar)..."
    cd hw/boards/icesugar
    ./build_spu13.sh top > /dev/null 2>&1
    echo "[PASS] iCeSugar forge is active."
fi

echo "--- AUDIT COMPLETE: Manifold is CRYSTALLINE. AUTHORIZED TO PUSH. ---"
