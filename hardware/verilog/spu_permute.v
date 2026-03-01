// SPU-1 Quadray Permutator (SPERM)
// Implements 60-degree rotation as a zero-gate register shuffle
// No arithmetic gates required.

module spu_permute (
    input  [255:0] q_in,  // 4 Lanes x 64-bit (a, b)
    output [255:0] q_out  // Rotated result
);

    // Quadray Lane Mapping:
    // Lane 1 [63:0]   - Q1
    // Lane 2 [127:64]  - Q2
    // Lane 3 [191:128] - Q3
    // Lane 4 [255:192] - Q4

    // _spu_rotate_60 around Q4 Axis:
    // Maps {Q1, Q2, Q3, Q4} -> {Q2, Q3, Q1, Q4}
    
    assign q_out[63:0]    = q_in[127:64];  // Q1_out = Q2_in
    assign q_out[127:64]  = q_in[191:128]; // Q2_out = Q3_in
    assign q_out[191:128] = q_in[63:0];    // Q3_out = Q1_in
    assign q_out[255:192] = q_in[255:192]; // Q4_out = Q4_in

endmodule
