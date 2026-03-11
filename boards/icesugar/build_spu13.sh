#!/bin/bash
# SPU-13 Reification Script: iCeSugar (v1.5 Lithic Edition)
# Target: Lattice iCE40UP5K-SG48

# 1. Configuration
TOP=${1:-top}
PROJ="spu13_cortex"
DEVICE="up5k"
PACKAGE="sg48"
PCF="spu13_icesugar_v2.pcf"
RTL_DIR="../../rtl"

# Source Toolchain Path
export PATH="/Users/johncurley/.apio/packages/oss-cad-suite/bin:$PATH"

echo "--- Initializing SPU-13 Manifold Synthesis: $TOP (iCeSugar) ---"

# 2. Source Files (Cortex + Artery)
SRC="spu13_cortex.v \
    spu13_lean_core.v \
    $RTL_DIR/spu_nano_core.v \
    $RTL_DIR/spu_davis_gate.v \
    $RTL_DIR/spu_quadrance_calc.v \
    $RTL_DIR/spu_gram_controller.v \
    $RTL_DIR/spu_dream_log.v \
    $RTL_DIR/spu_fractal_compressor.v \
    $RTL_DIR/spu_artery.v \
    $RTL_DIR/spu_artery_phy.v \
    $RTL_DIR/spu_whisper_rx.v \
    $RTL_DIR/spu_pwm_audio.v \
    $RTL_DIR/spu_harmonic_transducer.v \
    $RTL_DIR/spu_oled_visualizer.v \
    $RTL_DIR/spu_eink_waveshare_driver.v \
    $RTL_DIR/spu_ssd1306_driver.v \
    $RTL_DIR/uart_tx_mini.v \
    $RTL_DIR/uart_rx_mini.v \
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
