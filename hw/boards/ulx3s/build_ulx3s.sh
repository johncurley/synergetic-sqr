#!/bin/bash
# SPU-13 Reification Script: ULX3S (v3.4.22)
# Target: Lattice ECP5-85k (LFE5U-85F)

# 1. Configuration
TOP=${1:-ulx3s_top}
PROJ="spu13_ulx3s"
DEVICE="LFE5U-85F"
PACKAGE="CABGA381"
LPF="ulx3s.lpf"
RTL_DIR="../../rtl"

# Source Toolchain Path
export PATH="/Users/johncurley/.apio/packages/oss-cad-suite/bin:$PATH"

echo "--- Initializing SPU-13 Manifold Synthesis: $TOP (ULX3S) ---"

# 2. Source Files
CORE_DIR="../../core"
SRC="lean_top.v \
    ../icesugar/spu13_lean_core.v \
    $CORE_DIR/spu_nano_core.v \
    $CORE_DIR/spu_davis_gate.v \
    $CORE_DIR/spu_resonant_heart.v \
    $CORE_DIR/spu_whisper_sane.v \
    $CORE_DIR/spu_soul_metabolism.v \
    $CORE_DIR/spu_flash_controller.v \
    $CORE_DIR/spu_fractal_clk.v \
    $CORE_DIR/spu_ssd1306_driver.v \
    $CORE_DIR/surd_uart_tx.v"

# 3. Synthesis (Yosys)
yosys -p "synth_ecp5 -top $TOP -json $PROJ.json" $SRC

# 4. Place & Route (nextpnr)
nextpnr-ecp5 --85k --package $PACKAGE --json $PROJ.json --lpf $LPF --textcfg $PROJ.config --lpf-allow-unconstrained

# 5. Packaging (ecppack)
ecppack $PROJ.config $PROJ.bit

echo "--- Build Complete: $PROJ.bit is ready for Reification ---"
