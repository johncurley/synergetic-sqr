#!/bin/bash
# SPU-13 Sovereign Build Script: ULX3S
# Target: Lattice ECP5-85k

TOP="spu13_ulx3s_sovereign"
PROJ="spu13_sovereign_ulx3s"
DEVICE="LFE5U-85F"
PACKAGE="CABGA381"
LPF="ulx3s.lpf"

# Source Files
SRC="spu13_ulx3s_sovereign.v \
    ../../core/spu13_decoder.v \
    ../../core/vector_to_parabola.v \
    ../../core/uart_rx_mini.v"

echo "--- Synthesizing Sovereign HAL for ULX3S ---"

# Synthesis
yosys -p "synth_ecp5 -top $TOP -json $PROJ.json" $SRC

# P&R
nextpnr-ecp5 --85k --package $PACKAGE --json $PROJ.json --lpf $LPF --textcfg $PROJ.config --lpf-allow-unconstrained

# Pack
ecppack $PROJ.config $PROJ.bit

echo "--- Build Complete: $PROJ.bit ---"
