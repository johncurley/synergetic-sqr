#!/bin/bash
# SPU-13 Reification Script: Phase 1 (Resonant Anchor) (v3.3.7)
# Targets: iCE40UP5K (iCeSugar)

echo "--- Initializing SPU-13 Manifold Synthesis ---"

# 1. Synthesis (Yosys) - Creating the Logic Manifold
yosys -p "synth_ice40 -top spu13_top -json spu13.json" \
    spu13_top.v \
    ../../rtl/spu_fractal_clk.v \
    ../../rtl/spu_coherence_ecc.v \
    ../../rtl/spu_rational_trig.v \
    ../../rtl/spu_geometry_fluidizer.v \
    ../../rtl/spu_gram_controller.v \
    ../../rtl/spu_fluid_solver.v \
    ../../rtl/spu_annealer.v \
    ../../rtl/spu_tensegrity_balancer.v \
    ../../rtl/spu_harmonic_vis.v \
    ../../rtl/spu_identity_monad.v \
    ../../rtl/spu_fractal_bypass.v

# 2. Place & Route (nextpnr) - Mapping the IVM Geometry
# Using --force to allow for Virtual Induction 'unconnected' pins
nextpnr-ice40 --up5k --package sg48 --json spu13.json --pcf spu13_icesugar_v2.pcf --asc spu13.asc

# 3. Bitstream Timing Check - Verifying Null Hysteresis
icetime -d up5k -P sg48 -t spu13.asc

# 4. Packaging - Generating the Reified Bitstream
icepack spu13.asc spu13.bin

echo "--- Build Complete: spu13.bin is ready for the Primer Phase ---"
