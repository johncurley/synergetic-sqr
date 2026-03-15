#!/bin/bash
# SPU-13 Sovereign Build Script: Tang Nano 20K
# Target: Gowin GW2AR-18

TOP="spu13_tang_nano_sovereign"
PROJ="spu13_sovereign_gowin"
DEVICE="GW2AR-LV18QN88C8/I7"
CST="tang_nano_20k.cst" # Reusing main CST for pins

# Source Files
SRC="spu13_tang_nano_sovereign.v \
    ../../core/spu13_decoder.v \
    ../../core/vector_to_parabola.v \
    ../../core/uart_rx_mini.v"

echo "--- Synthesizing Sovereign HAL for Tang Nano 20K ---"

# Synthesis
yosys -ql design.log -p "read_verilog -sv $SRC; synth_gowin -top $TOP -json $PROJ.json"

# P&R
nextpnr-himbaechel --device $DEVICE --vopt family=GW2A-18 --vopt cst=$CST --json $PROJ.json --write $PROJ.fs_json

# Pack
gowin_pack -d GW2A-18 -o $PROJ.fs $PROJ.fs_json

echo "--- Build Complete: $PROJ.fs ---"
