# SPU-13 Arty A7 Automated Build Script (v2.9.25)
# Objective: Deterministic Hardware Synthesis for the Synergetic Ecosystem.
# Usage: vivado -mode batch -source build_spu13.tcl

set project_name "SPU13_Sunflower"
set device "xc7a35ticsg324-1L" ;# Arty A7-35T
set outputDir ./build_output
file mkdir $outputDir

# 1. Setup Project
create_project $project_name ./$project_name -part $device -force

# 2. Add Sources (SQR-ALU, G-RAM, and Laminar Power)
add_files [glob ./verilog/*.v]
add_files -fileset constrs_1 ./verilog/spu_arty_a7.xdc

# 3. Run Synthesis (Optimizing for Geometric Alignment)
# Flatten hierarchy is set to 'rebuilt' to preserve Isotropic logic paths.
synth_design -top arty_a7_top -part $device -flatten_hierarchy rebuilt
write_checkpoint -force $outputDir/post_synth.dcp

# 4. Implementation (Place and Route)
opt_design
place_design
route_design
report_timing_summary -file $outputDir/timing_summary.txt

# 5. Generate Bitstream
write_bitstream -force $outputDir/spu13_flower.bit
puts "Henosis Achieved: Bitstream generated at $outputDir/spu13_flower.bit"
