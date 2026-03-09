#!/bin/bash
# SPU-13 Reification Script: Universal Build (v3.3.47)
# Targets: iCE40UP5K (iCeSugar)

# 1. Configuration
TOP=${1:-spu13_golden_reification} # Default to unboxing ceremony core
PROJ="spu13_icesugar"
DEVICE="up5k"
PACKAGE="sg48"
RTL_DIR="../../rtl"

if [ "$TOP" == "spu13_golden_reification" ] || [ "$TOP" == "icesugar_full_manifold" ]; then
    PCF="spu13_icesugar_full.pcf"
else
    PCF="spu13_icesugar_v2.pcf"
fi

echo "--- Initializing SPU-13 Manifold Synthesis: $TOP ---"

# 2. Source List
SRC="$TOP.v \
    $RTL_DIR/spu_fractal_clk.v \
    $RTL_DIR/spu_harmonic_handshake.v \
    $RTL_DIR/spu_bowman_sequencer.v \
    $RTL_DIR/spu_coherence_ecc.v \
    $RTL_DIR/spu_core.v \
    $RTL_DIR/spu_ecc.v \
    $RTL_DIR/spu_permute.v \
    $RTL_DIR/spu_permute_13.v \
    $RTL_DIR/spu_smul_13.v \
    $RTL_DIR/spu_lattice_13.v \
    $RTL_DIR/spu_rational_trig.v \
    $RTL_DIR/spu_geometry_fluidizer.v \
    $RTL_DIR/spu_gram_controller.v \
    $RTL_DIR/spu_fluid_solver.v \
    $RTL_DIR/spu_annealer.v \
    $RTL_DIR/spu_tensegrity_balancer.v \
    $RTL_DIR/spu_harmonic_vis.v \
    $RTL_DIR/spu_identity_monad.v \
    $RTL_DIR/spu_fractal_bypass.v \
    $RTL_DIR/spu_self_test.v \
    $RTL_DIR/spu_io_bridge.v \
    $RTL_DIR/surd_uart_tx.v \
    $RTL_DIR/surd_multiplier.v \
    $RTL_DIR/spu_rational_snap.v \
    $RTL_DIR/spu_proprioception.v \
    $RTL_DIR/spu_validator.v \
    $RTL_DIR/spu_metabolic_sense.v \
    $RTL_DIR/spu_thalamus.v \
    $RTL_DIR/spu_harmonic_transducer.v \
    $RTL_DIR/spu_laminar_power.v \
    $RTL_DIR/spu_laminar_gate.v \
    $RTL_DIR/spu_oled_visualizer.v"

# 3. Synthesis (Yosys)
yosys -p "synth_ice40 -top $TOP -json $PROJ.json" $SRC

# 4. Place & Route (nextpnr)
nextpnr-ice40 --$DEVICE --package $PACKAGE --json $PROJ.json --pcf $PCF --asc $PROJ.asc

# 5. Timing Audit (icetime)
icetime -d $DEVICE -P $PACKAGE -t $PROJ.asc

# 6. Packaging (icepack)
icepack $PROJ.asc $PROJ.bin

echo "--- Build Complete: $PROJ.bin is ready for Reification ---"
