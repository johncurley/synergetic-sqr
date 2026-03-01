// SPU-1 Surd Multiplier Unit (SMUL)
// Implements (a1 + b1*sqrt3) * (a2 + b2*sqrt3) / 2^16
// Bit-exact with SPU-1 Software Specification

module spu_smul (
    input  signed [31:0] a1,
    input  signed [31:0] b1,
    input  signed [31:0] a2,
    input  signed [31:0] b2,
    output signed [31:0] a_out,
    output signed [31:0] b_out
);

    // 1. Calculate Intermediate Products (64-bit to prevent overflow)
    // Hardware: 4 x 32-bit multipliers
    wire signed [63:0] p1 = a1 * a2;
    wire signed [63:0] p2 = b1 * b2;
    wire signed [63:0] p3 = a1 * b2;
    wire signed [63:0] p4 = b1 * a2;

    // 2. Optimized Surd Term (p2 * 3)
    // SPU-1 Gate Logic: (x << 1) + x (Zero multiplier overhead)
    wire signed [63:0] surd_term = (p2 << 1) + p2;

    // 3. Final Summation and Fixed-Point Shift
    // Arithmetic right shift (>>>) ensures sign preservation.
    assign a_out = (p1 + surd_term) >>> 16;
    assign b_out = (p3 + p4) >>> 16;

endmodule
