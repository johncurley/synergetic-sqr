// SPU-13 Phi-Core Multiplier (SMUL_13)
// Implements (a1 + b1*sqrt3 + c1*sqrt5 + d1*sqrt15) * (a2 + b2*sqrt3 + c2*sqrt5 + d2*sqrt15)
// Bit-exact with SPU-13 Golden Core Specification (v3.1.4).

module spu_smul_13 (
    input  signed [31:0] a1, b1, c1, d1,
    input  signed [31:0] a2, b2, c2, d2,
    output signed [31:0] res_a, res_b, res_c, res_d
);

    // 1. Cross-Products (64-bit intermediates)
    wire signed [63:0] aa = a1 * a2;
    wire signed [63:0] bb = b1 * b2;
    wire signed [63:0] cc = c1 * c2;
    wire signed [63:0] dd = d1 * d2;
    
    wire signed [63:0] ab = a1 * b2 + b1 * a2;
    wire signed [63:0] ac = a1 * c2 + c1 * a2;
    wire signed [63:0] ad = a1 * d2 + d1 * a2;
    wire signed [63:0] bc = b1 * c2 + c1 * b2;
    wire signed [63:0] bd = b1 * d2 + d1 * b2;
    wire signed [63:0] cd = c1 * d2 + d1 * c2;

    // 2. Field Combination Logic (Q(3,5) basis)
    // res_a = aa + 3bb + 5cc + 15dd
    // res_b = ab + 5cd
    // res_c = ac + 3bd
    // res_d = ad + bc
    
    assign res_a = (aa + (bb*3) + (cc*5) + (dd*15)) >>> 16;
    assign res_b = (ab + (cd*5)) >>> 16;
    assign res_c = (ac + (bd*3)) >>> 16;
    assign res_d = (ad + bc) >>> 16;

endmodule
