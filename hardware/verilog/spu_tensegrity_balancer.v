// SPU-1 Tensegrity Balancer (v1.11.4 logic)
// Input: 12 Neighbor Quadray Vectors (3072 bits)
// Output: Equilibrium Correction Vector toward Isotropic Center

module spu_tensegrity_balancer (
    input clk,
    input reset,
    input [3071:0] neighbors, // 12 * 256-bit quadray registers
    output reg [255:0] correction_vector
);

    // Stage 1 Sums
    wire [255:0] s1_0, s1_1, s1_2, s1_3, s1_4, s1_5;
    spu_sadd a1_0(neighbors[255:0],    neighbors[511:256],   s1_0);
    spu_sadd a1_1(neighbors[767:512],   neighbors[1023:768],  s1_1);
    spu_sadd a1_2(neighbors[1279:1024], neighbors[1535:1280], s1_2);
    spu_sadd a1_3(neighbors[1791:1536], neighbors[2047:1792], s1_3);
    spu_sadd a1_4(neighbors[2303:2048], neighbors[2559:2304], s1_4);
    spu_sadd a1_5(neighbors[2815:2560], neighbors[3071:2816], s1_5);

    // Stage 2 Sums
    wire [255:0] s2_0, s2_1, s2_2;
    spu_sadd a2_0(s1_0, s1_1, s2_0);
    spu_sadd a2_1(s1_2, s1_3, s2_1);
    spu_sadd a2_2(s1_4, s1_5, s2_2);

    // Stage 3 Sums (Final Accumulation)
    wire [255:0] s3_0, final_sum;
    spu_sadd a3_0(s2_0, s2_1, s3_0);
    spu_sadd a3_1(s3_0, s2_2, final_sum);

    // Sequential Output Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correction_vector <= 256'h0;
        end else begin
            // Correction is the two's complement inversion of the sum per lane
            correction_vector[31:0]    <= ~final_sum[31:0]    + 1'b1;
            correction_vector[63:32]   <= ~final_sum[63:32]   + 1'b1;
            correction_vector[95:64]   <= ~final_sum[95:64]   + 1'b1;
            correction_vector[127:96]  <= ~final_sum[127:96]  + 1'b1;
            correction_vector[159:128] <= ~final_sum[159:128] + 1'b1;
            correction_vector[191:160] <= ~final_sum[191:160] + 1'b1;
            correction_vector[223:192] <= ~final_sum[223:192] + 1'b1;
            correction_vector[255:224] <= ~final_sum[255:224] + 1'b1;
        end
    end

endmodule
