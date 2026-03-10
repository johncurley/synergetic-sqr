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
SRC="lean_top.v \
    ../icesugar/spu13_lean_core.v \
    $RTL_DIR/spu_fractal_clk.v \
    $RTL_DIR/spu_harmonic_handshake.v \
    $RTL_DIR/spu_bowman_sequencer.v \
    $RTL_DIR/spu_coherence_ecc.v \
    $RTL_DIR/spu_core.v \
    $RTL_DIR/spu_ecc.v \
    $RTL_DIR/spu_permute.v \
    $RTL_DIR/spu_permute_13.v \
    $RTL_DIR/spu_smul_13.v \
    $RTL_DIR/spu_lattice_4.v \
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
    $RTL_DIR/spu_laminar_buffer.v \
    $RTL_DIR/spu13_rotor_core.v \
    $RTL_DIR/spu_ssd1306_driver.v \
    $RTL_DIR/spu_oled_visualizer.v \
    $RTL_DIR/spu_viscosity_monitor.v"

# 3. Synthesis (Yosys)
yosys -p "synth_ecp5 -top $TOP -json $PROJ.json" $SRC

# 4. Place & Route (nextpnr)
nextpnr-ecp5 --85k --package $PACKAGE --json $PROJ.json --lpf $LPF --textcfg $PROJ.config --lpf-allow-unconstrained

# 5. Packaging (ecppack)
ecppack $PROJ.config $PROJ.bit

echo "--- Build Complete: $PROJ.bit is ready for Reification ---"
