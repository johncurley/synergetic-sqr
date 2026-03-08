# SPU-13 Arty A7 Automated Build Script (v3.3.59)
# Objective: 13-Core Collective Manifold Synthesis.
# Usage: vivado -mode batch -source build_spu13.tcl

set project_name "SPU13_Collective"
set device "xc7a35ticsg324-1L" ;# Arty A7-35T
set outputDir ./build_output
file mkdir $outputDir

# 1. Setup Project
create_project $project_name ./$project_name -part $device -force

# 2. Add Sources (Collective Lattice and dependencies)
add_files top.v
add_files ../../rtl/spu_core.v
add_files ../../rtl/spu_lattice_13.v
add_files ../../rtl/spu_fractal_clk.v
add_files ../../rtl/spu_harmonic_handshake.v
add_files ../../rtl/spu_coherence_ecc.v
add_files ../../rtl/spu_ecc.v
add_files ../../rtl/spu_permute.v
add_files ../../rtl/spu_permute_13.v
add_files ../../rtl/spu_smul_13.v
add_files ../../rtl/spu_rational_trig.v
add_files ../../rtl/spu_geometry_fluidizer.v
add_files ../../rtl/spu_gram_controller.v
add_files ../../rtl/spu_fluid_solver.v
add_files ../../rtl/spu_annealer.v
add_files ../../rtl/spu_tensegrity_balancer.v
add_files ../../rtl/spu_harmonic_vis.v
add_files ../../rtl/spu_identity_monad.v
add_files ../../rtl/spu_fractal_bypass.v
add_files ../../rtl/spu_self_test.v
add_files ../../rtl/spu_io_bridge.v
add_files ../../rtl/surd_uart_tx.v
add_files ../../rtl/surd_multiplier.v

add_files -fileset constrs_1 spu_arty_a7.xdc

# 3. Run Synthesis
synth_design -top arty_a7_top -part $device -flatten_hierarchy rebuilt
write_checkpoint -force $outputDir/post_synth.dcp

# 4. Implementation
opt_design
place_design
route_design
report_timing_summary -file $outputDir/timing_summary.txt

# 5. Generate Bitstream
write_bitstream -force $outputDir/spu13_collective.bit
puts "Collective Resonance Achieved: Bitstream generated at $outputDir/spu13_collective.bit"
