#!/bin/bash
# SPU-13 Ephemeralization Script: iCeSugar Nano (v1.1)
# Target: Lattice iCE40LP1K-CM36 (1,280 LUTs)

# 1. Configuration
TOP=${1:-top_guardian}
PROJ="spu13_nano_guardian"
DEVICE="lp1k"
PACKAGE="cm36"
PCF="nano.pcf"
RTL_DIR="../../rtl"

# Source Toolchain Path
export PATH="/Users/johncurley/.apio/packages/oss-cad-suite/bin:$PATH"

echo "--- Initializing SPU-13 Seed Synthesis: $TOP (iCeSugar Nano) ---"

# 2. Source Files (Surgical List for 1k Limit)
if [ "$TOP" == "top_guardian" ]; then
    SRC="top_guardian.v \
        ../../core/spu_resonant_heart.v \
        ../../core/spu_whisper_sane.v \
        ../../core/spu_soul_metabolism.v \
        ../../core/spu_flash_controller.v \
        ../../core/spu_serial_davis_gate.v \
        ../../core/spu_serial_multiplier.v \
        ../../core/spu_whisper_tx.v"
else
    SRC="top.v \
        $RTL_DIR/spu_nano_core.v \
        $RTL_DIR/spu_serial_davis_gate.v \
        $RTL_DIR/spu_serial_multiplier.v \
        $RTL_DIR/surd_uart_tx.v"
fi

# 3. Synthesis (Yosys)
yosys -ql design.log -p "synth_ice40 -top $TOP -json $PROJ.json" $SRC

# 4. Place & Route (nextpnr)
nextpnr-ice40 --$DEVICE --package $PACKAGE --json $PROJ.json --pcf $PCF --asc $PROJ.asc --pcf-allow-unconstrained

# 5. Packaging (icepack)
icepack $PROJ.asc $PROJ.bin

echo "--- Seed Reified: $PROJ.bin ready for Ephemeralization ---"
