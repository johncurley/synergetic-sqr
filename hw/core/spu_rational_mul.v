// SPU-13 Rational Multiplier (v1.0)
// Target: iCE40UP5K DSP Blocks (16x16 -> 32)
// Objective: Single-cycle rational scaling for Quadrance and IVM.
// Logic: (A * B) >> 16 for fixed-point resonance.

module spu_rational_mul (
    input  wire        clk,
    input  wire [15:0] a, // 1.15 Fixed-point
    input  wire [15:0] b, // 1.15 Fixed-point
    output wire [15:0] res // Result in 1.15
);

    wire [31:0] full_prod;

    // Use Lattice SB_MAC16 for single-cycle DSP execution
    SB_MAC16 #(
        .NEG_TRIGGER(1'b0),
        .C_REG(1'b0),
        .A_REG(1'b0),
        .B_REG(1'b0),
        .D_REG(1'b0),
        .TOP_8x8_MULT_REG(1'b0),
        .BOT_8x8_MULT_REG(1'b0),
        .PIPELINE_16x16_MULT_REG1(1'b0),
        .PIPELINE_16x16_MULT_REG2(1'b0)
    ) u_dsp (
        .CLK(clk),
        .CE(1'b1),
        .A(a),
        .B(b),
        .C(16'b0),
        .D(16'b0),
        .O(full_prod)
    );

    // Scale back to 1.15 (Discard low bits)
    assign res = full_prod[30:15];

endmodule
