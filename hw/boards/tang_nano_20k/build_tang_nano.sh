#!/bin/bash
# SPU-13 Reification Script: Tang Nano 20K (v1.2 HAL)
# Target: Gowin GW2AR-18C (GW2AR-LV18QN88C8/I7)

# 1. Configuration
TOP=${1:-tang_nano_20k_top}
PROJ="spu13_tang_nano"
DEVICE="GW2AR-LV18QN88C8/I7"
CST="Laminar_Gowin.cst"
RTL_DIR="../../rtl"

# Source Toolchain Path
export PATH="/Users/johncurley/.apio/packages/oss-cad-suite/bin:$PATH"

echo "--- Initializing SPU-13 Manifold Synthesis: $TOP (Tang Nano 20K) ---"

# 2. Source Files (Surgical Parity List)
CORE_DIR="../../core"
SRC="lean_top.v \
    ../icesugar/spu13_lean_core.v \
    $CORE_DIR/spu_nano_core.v \
    $CORE_DIR/spu_davis_gate.v \
    $CORE_DIR/spu_resonant_heart.v \
    $CORE_DIR/spu_whisper_sane.v \
    $CORE_DIR/spu_soul_metabolism.v \
    $CORE_DIR/spu_flash_controller.v \
    $CORE_DIR/spu_ssd1306_driver.v \
    $CORE_DIR/surd_uart_tx.v"

# 3. Synthesis (Yosys)
yosys -ql design.log -p "read_verilog -sv $SRC; synth_gowin -top $TOP -json $PROJ.json"

# 4. Place & Route (nextpnr-himbaechel)
nextpnr-himbaechel --device $DEVICE --vopt family=GW2A-18 --vopt cst=$CST --json $PROJ.json --write $PROJ.fs_json

# 5. Packaging (gowin_pack)
gowin_pack -d GW2A-18 -o $PROJ.fs $PROJ.fs_json

echo "--- Build Complete: $PROJ.fs is ready for Reification ---"
