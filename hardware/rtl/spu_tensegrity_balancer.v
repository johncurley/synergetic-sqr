// SPU-1 Pipelined Tensegrity Balancer (v2.0.27)
// Implements a 4-stage reduction tree for 12-neighbor Laplacian relaxation.
// Stage 4 registers the final output for clean bus timing.

module spu_tensegrity_balancer (
    input  clk,
    input  reset,
    input  [3071:0] neighbors, 
    output reg [255:0] scaled_residual
);

    // Intermediate registers for pipelining
    reg signed [63:0] s1 [0:7][0:5]; // Stage 1
    reg signed [63:0] s2 [0:7][0:2]; // Stage 2
    reg signed [63:0] s3 [0:7];      // Stage 3

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : lane_logic
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

            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    s1[i][0] <= 64'd0; s1[i][1] <= 64'd0; s1[i][2] <= 64'd0;
                    s1[i][3] <= 64'd0; s1[i][4] <= 64'd0; s1[i][5] <= 64'd0;
                    s2[i][0] <= 64'd0; s2[i][1] <= 64'd0; s2[i][2] <= 64'd0;
                    s3[i]    <= 64'd0;
                    scaled_residual[i*32 +: 32] <= 32'd0;
                end else begin
                    // Stage 1: Reduction 1
                    s1[i][0] <= $signed(n[0])  + $signed(n[1]);
                    s1[i][1] <= $signed(n[2])  + $signed(n[3]);
                    s1[i][2] <= $signed(n[4])  + $signed(n[5]);
                    s1[i][3] <= $signed(n[6])  + $signed(n[7]);
                    s1[i][4] <= $signed(n[8])  + $signed(n[9]);
                    s1[i][5] <= $signed(n[10]) + $signed(n[11]);

                    // Stage 2: Reduction 2
                    s2[i][0] <= s1[i][0] + s1[i][1];
                    s2[i][1] <= s1[i][2] + s1[i][3];
                    s2[i][2] <= s1[i][4] + s1[i][5];

                    // Stage 3: Final reduction
                    s3[i] <= s2[i][0] + s2[i][1] + s2[i][2];

                    // Stage 4: Register Output with Scaling (alpha = 1/16)
                    scaled_residual[i*32 +: 32] <= s3[i] >>> 4;
                end
            end
        end
    endgenerate

endmodule
