#!/bin/bash
# SPU-13 Reification Script: iCeSugar Nano (v1.3 HAL)
# Target: Lattice iCE40UP5K-SG48

# 1. Configuration
TOP=${1:-spu13_lean_core}
PROJ="spu13_icesugar"
DEVICE="up5k"
PACKAGE="sg48"
PCF="spu13_icesugar_v2.pcf"
RTL_DIR="../../rtl"

# Source Toolchain Path (Apio / OSS-CAD-Suite)
export PATH="/Users/johncurley/.apio/packages/oss-cad-suite/bin:$PATH"

echo "--- Initializing SPU-13 Manifold Synthesis: $TOP (iCeSugar) ---"

# 2. Source Files (Surgical List for 5k Gate Limit)
SRC="$TOP.v \
    $RTL_DIR/spu_nano_core.v \
    $RTL_DIR/spu_davis_gate.v \
    $RTL_DIR/spu_quadrance_calc.v \
    $RTL_DIR/spu_gram_controller.v \
    $RTL_DIR/spu_ssd1306_driver.v \
    $RTL_DIR/surd_uart_tx.v"

# 3. Synthesis (Yosys)
yosys -ql design.log -p "synth_ice40 -top $TOP -json $PROJ.json" $SRC

# 4. Place & Route (nextpnr)
nextpnr-ice40 --$DEVICE --package $PACKAGE --json $PROJ.json --pcf $PCF --asc $PROJ.asc --pcf-allow-unconstrained

# 5. Timing Audit (icetime)
icetime -d $DEVICE -P $PACKAGE -t $PROJ.asc

# 6. Packaging (icepack)
icepack $PROJ.asc $PROJ.bin

echo "--- Build Complete: $PROJ.bin is ready for Reification ---"
