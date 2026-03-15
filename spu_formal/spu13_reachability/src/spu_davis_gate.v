// SPU-13 Davis Gate (v1.2 DSP-Optimized)
// Objective: Monitor Lattice Tension using dedicated iCE40 DSP Slices.
// Logic: 16-bit inputs map 1:1 to SB_MAC16 for zero LUT overhead.
// Discovery: Bee Davis, "The Geometry of Sameness"

module spu_davis_gate #(
    parameter [31:0] TAU_Q = 32'h0400 // tau^2 in 16-bit fixed-point
)(
    input  wire signed [15:0] a,
    input  wire signed [15:0] b,
    input  wire signed [15:0] c,
    input  wire signed [15:0] d,
    output wire over_curvature
);

    // 1. Quadrance Q = A^2 + B^2 + C^2 + D^2
    // These multipliers will be inferred as DSP slices by Yosys.
    wire signed [31:0] qa = a * a;
    wire signed [31:0] qb = b * b;
    wire signed [31:0] qc = c * c;
    wire signed [31:0] qd = d * d;
    
    wire [31:0] q_sum = qa + qb + qc + qd;

    // 2. The Davis Limit
    assign over_curvature = (q_sum > TAU_Q);

endmodule
