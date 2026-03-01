// SPU-1 Hardened Tensegrity Balancer (v2.0.21)
// Input: 12 Neighbor Relational Bond Vectors (3072 bits)
// Output: Hardened Correction Vector (32-bit lanes)
// Corrected syntax for synthesizable bit-range assignment.

module spu_tensegrity_balancer (
    input clk,
    input reset,
    input [3071:0] neighbors, 
    output reg [255:0] correction_vector
);

    wire [31:0] next_correction [0:7];

    // Parallel Accumulation (8 SIMD lanes)
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : lane_logic
            wire signed [31:0] n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11;
            assign n0  = neighbors[0*256 + i*32 +: 32];
            assign n1  = neighbors[1*256 + i*32 +: 32];
            assign n2  = neighbors[2*256 + i*32 +: 32];
            assign n3  = neighbors[3*256 + i*32 +: 32];
            assign n4  = neighbors[4*256 + i*32 +: 32];
            assign n5  = neighbors[5*256 + i*32 +: 32];
            assign n6  = neighbors[6*256 + i*32 +: 32];
            assign n7  = neighbors[7*256 + i*32 +: 32];
            assign n8  = neighbors[8*256 + i*32 +: 32];
            assign n9  = neighbors[9*256 + i*32 +: 32];
            assign n10 = neighbors[10*256 + i*32 +: 32];
            assign n11 = neighbors[11*256 + i*32 +: 32];

            // 64-bit Summation
            wire signed [63:0] full_sum = 
                $signed(n0) + $signed(n1) + $signed(n2) + $signed(n3) +
                $signed(n4) + $signed(n5) + $signed(n6) + $signed(n7) +
                $signed(n8) + $signed(n9) + $signed(n10) + $signed(n11);

            // Isotropic Scaling + Inversion
            wire signed [31:0] scaled = full_sum[35:4]; // Equivalent to >>> 4 then truncate
            assign next_correction[i] = ~scaled + 1'b1;
        end
    endgenerate

    // Sequential Output Update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correction_vector <= 256'h0;
        end else begin
            correction_vector <= {
                next_correction[7], next_correction[6], next_correction[5], next_correction[4],
                next_correction[3], next_correction[2], next_correction[1], next_correction[0]
            };
        end
    end

endmodule
