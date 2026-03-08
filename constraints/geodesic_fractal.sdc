# SPU-13 Geodesic Fractal Timing Constraints (SDC)
# Objective: Bit-Exact Phase Alignment at 61.44 kHz

# 1. Create Resonant Clock
create_clock -period 16276.0 -name clk_resonant [get_ports clk_resonant]

# 2. Enforce Zero-Skew Wavefront
# All Quadray lanes (ABCD) must have identical propagation delay.
set_clock_uncertainty -setup 0.1 [get_clocks clk_resonant]
set_clock_uncertainty -hold  0.1 [get_clocks clk_resonant]

# 3. Geodesic Path Delays
# Constrain inter-core paths to remain bit-exact.
# We define max delay as a multiple of the resonant period / 1024 (The Jitter Guard).
set_max_delay 15.0 -from [get_cells u_core/reg_curr_*] -to [get_cells u_core/reg_out_*]

# 4. Turbulence Suppression
# False paths are disallowed; every signal must follow the manifold.
set_disable_timing [get_cells -hierarchical *cubic_stutter*]
