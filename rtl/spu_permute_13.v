// SPU-13 High-Dimensional Permutator (v3.3.28)
// Implements 13-axis cyclic shuffle: {Q1..Q13} -> {Q2..Q13, Q1}
// Aligned with the Symmetry of the 13 for Topological Data Folding.
// Logic: Zero-Gate Wiring Permutation.

module spu_permute_13 (
    input  wire [831:0] q_in,  // 13 Lanes x 64-bit
    output wire [831:0] q_out
);

    // Named Lane Extraction
    wire [63:0] q1  = q_in[63:0];
    wire [63:0] q2  = q_in[127:64];
    wire [63:0] q3  = q_in[191:128];
    wire [63:0] q4  = q_in[255:192];
    wire [63:0] q5  = q_in[319:256];
    wire [63:0] q6  = q_in[383:320];
    wire [63:0] q7  = q_in[447:384];
    wire [63:0] q8  = q_in[511:448];
    wire [63:0] q9  = q_in[575:512];
    wire [63:0] q10 = q_in[639:576];
    wire [63:0] q11 = q_in[703:640];
    wire [63:0] q12 = q_in[767:704];
    wire [63:0] q13 = q_in[831:768];

    // Cyclic 13-Axis Shift (Zero-Gate Logic)
    // Formula: q_out[i] = q_in[(i+1)%13]
    assign q_out = { q1, q13, q12, q11, q10, q9, q8, q7, q6, q5, q4, q3, q2 };

endmodule
