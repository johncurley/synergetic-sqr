// SPU-13 Phi-Core Multiplier (SMUL_13)
// Implements (a1 + b1*sqrt3 + c1*sqrt5 + d1*sqrt15) * (a2 + b2*sqrt3 + c2*sqrt5 + d2*sqrt15)
// Bit-exact with SPU-13 Golden Core Specification.

module spu_smul_13 (
    input  signed [31:0] a1, b1, c1, d1,
    input  signed [31:0] a2, b2, c2, d2,
    output signed [31:0] a_out, b_out, c_out, d_out
);

    // 1. All 16 Cross-Products (64-bit intermediates)
    wire signed [63:0] aa = a1 * a2;
    wire signed [63:0] ab = a1 * b2;
    wire signed [63:0] ac = a1 * c2;
    wire signed [63:0] ad = a1 * d2;
    
    wire signed [63:0] ba = b1 * a2;
    wire signed [63:0] bb = b1 * b2;
    wire signed [63:0] bc = b1 * c2;
    wire signed [63:0] bd = b1 * d2;
    
    wire signed [63:0] ca = c1 * a2;
    wire signed [63:0] cb = c1 * b2;
    wire signed [63:0] cc = c1 * c2;
    wire signed [63:0] cd = c1 * d2;
    
    wire signed [63:0] da = d1 * a2;
    wire signed [63:0] db = d1 * b2;
    wire signed [63:0] dc = d1 * c2;
    wire signed [63:0] dd = d1 * d2;

    // 2. Field Combination Logic (Q(3,5) basis)
    // res_a = aa + 3*bb + 5*cc + 15*dd
    // res_b = ab + ba + 5*cd + 5*dc
    // res_c = ac + ca + 3*bd + 3*db
    // res_d = ad + da + bc + cb
    
    wire signed [63:0] sum_a = aa + (bb*3) + (cc*5) + (dd*15);
    wire signed [63:0] sum_b = ab + ba + (cd*5) + (dc*5);
    wire signed [63:0] sum_c = ac + ca + (bd*3) + (db*3);
    wire signed [63:0] sum_d = ad + da + bc + cb;

    // 3. Final Normalization (16-bit shift)
    assign a_out = sum_a >>> 16;
    assign b_out = sum_b >>> 16;
    assign c_out = sum_c >>> 16;
    assign d_out = sum_d >>> 16;

endmodule
