// SPU-1 Hardened Tensegrity Balancer (v2.0.20)
// Input: 12 Neighbor Relational Bond Vectors (3072 bits)
// Output: Hardened Correction Vector (32-bit lanes)
// Uses 64-bit intermediate accumulators to eliminate bit-width overflow.

module spu_tensegrity_balancer (
    input clk,
    input reset,
    input [3071:0] neighbors, // 12 * 256-bit quadray registers
    output reg [255:0] correction_vector
);

    // Parallel Accumulation Tree (8 SIMD lanes)
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : lane_accumulators
            // 1. Gather the 12 neighbor components for this specific lane
            wire signed [31:0] n[0:11];
            assign n[0]  = neighbors[0*256 + i*32 +: 32];
            assign n[1]  = neighbors[1*256 + i*32 +: 32];
            assign n[2]  = neighbors[2*256 + i*32 +: 32];
            assign n[3]  = neighbors[3*256 + i*32 +: 32];
            assign n[4]  = neighbors[4*256 + i*32 +: 32];
            assign n[5]  = neighbors[5*256 + i*32 +: 32];
            assign n[6]  = neighbors[6*256 + i*32 +: 32];
            assign n[7]  = neighbors[7*256 + i*32 +: 32];
            assign n[8]  = neighbors[8*256 + i*32 +: 32];
            assign n[9]  = neighbors[9*256 + i*32 +: 32];
            assign n[10] = neighbors[10*256 + i*32 +: 32];
            assign n[11] = neighbors[11*256 + i*32 +: 32];

            // 2. Perform 64-bit Summation (Headroom = 32 bits)
            wire signed [63:0] full_sum = 
                $signed(n[0])  + $signed(n[1])  + $signed(n[2])  + $signed(n[3])  +
                $signed(n[4])  + $signed(n[5])  + $signed(n[6])  + $signed(n[7])  +
                $signed(n[8])  + $signed(n[9])  + $signed(n[10]) + $signed(n[11]);

            // 3. Sequential Update with Isotropic Scaling (alpha = 1/16)
            // Correction = -(Sum / 16)
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    correction_vector[i*32 +: 32] <= 32'h0;
                end else begin
                    // Arithmetic shift (>>>) preserves sign bit
                    // Bit-Inversion (~ + 1) for restoration pull
                    wire signed [63:0] scaled_sum = full_sum >>> 4;
                    correction_vector[i*32 +: 32] <= ~(scaled_sum[31:0]) + 1'b1;
                end
            end
        end
    endgenerate

endmodule
