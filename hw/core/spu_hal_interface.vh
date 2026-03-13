// SPU-13 Modular HAL Interface (v1.1)
// Objective: Standardized 'Laminar Display Bus' for the Symmetry Engine.
// Result: Portability across Cartesian, Vector, and Hex displays.

`ifndef SPU_HAL_INTERFACE_VH
`define SPU_HAL_INTERFACE_VH

// Signals defining the contract between the Quadray Core and the Display HAL
`define LAMINAR_DISPLAY_BUS \
    input  wire [15:0] q_a, q_b, q_c, q_d, \
    input  wire [31:0] rational_scale,     \
    input  wire        pulse_61k,          \
    input  wire        frame_sync,         \
    input  wire [1:0]  manifold_depth,     \
    output wire        display_ready

`endif
