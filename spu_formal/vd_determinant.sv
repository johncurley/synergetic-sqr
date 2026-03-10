// SPU-13 Formal Verification: Vd Determinant Invariant (v3.1.29)
// Field: Q(sqrt(3))
// Invariant: det(M) = F^3 + G^3 + H^3 - 3FGH = 1.0
// Basis: Tetrahedral Symmetry (F+G+H = 1.0)

module vd_determinant_formal (
    input  wire        clk,
    input  wire        rst_n,
    
    // Rotation Coefficients (F,G,H) in Q(sqrt(3))
    // Format: [63:32] Surd (S), [31:0] Integer (I)
    input  wire [63:0] F, G, H
);

`ifdef FORMAL

    // --- 1. Surd Field Arithmetic Helpers ---
    
    // Exact Surd Multiplication: (i1 + s1*sqrt3) * (i2 + s2*sqrt3)
    function [63:0] surd_mul(input [63:0] a, input [63:0] b);
        reg signed [31:0] i1, s1, i2, s2;
        reg signed [127:0] res_i, res_s;
        begin
            i1 = a[31:0]; s1 = a[63:32];
            i2 = b[31:0]; s2 = b[63:32];
            
            // Rule: (i1*i2 + 3*s1*s2) + (i1*s2 + s1*i2)sqrt(3)
            res_i = (128'(i1) * i2) + (3 * (128'(s1) * s2));
            res_s = (128'(i1) * s2) + (128'(s1) * i2);
            
            // SPU-13 normalization (16-bit shift for 16.16 fixed point)
            surd_mul = {res_s[47:16], res_i[47:16]};
        end
    endfunction

    function [63:0] surd_add(input [63:0] a, input [63:0] b);
        surd_add = {32'(a[63:32] + b[63:32]), 32'(a[31:0] + b[31:0])};
    endfunction

    function [63:0] surd_sub(input [63:0] a, input [63:0] b);
        surd_sub = {32'(a[63:32] - b[63:32]), 32'(a[31:0] - b[31:0])};
    endfunction

    // --- 2. Determinant Components ---
    
    wire [63:0] F2 = surd_mul(F, F);
    wire [63:0] F3 = surd_mul(F2, F);
    
    wire [63:0] G2 = surd_mul(G, G);
    wire [63:0] G3 = surd_mul(G2, G);
    
    wire [63:0] H2 = surd_mul(H, H);
    wire [63:0] H3 = surd_mul(H2, H);
    
    wire [63:0] FG  = surd_mul(F, G);
    wire [63:0] GH  = surd_mul(G, H);
    wire [63:0] HF  = surd_mul(H, F);
    wire [63:0] FGH = surd_mul(FG, H);
    
    // 3*FGH logic
    wire [63:0] three_FGH = {32'(FGH[63:32] * 3), 32'(FGH[31:0] * 3)};

    // det(M) = F^3 + G^3 + H^3 - 3FGH
    wire [63:0] det_M = surd_sub(surd_add(F3, surd_add(G3, H3)), three_FGH);

    // --- 3. Tetrahedral Constraints ---

    wire [63:0] sum_FGH = surd_add(F, surd_add(G, H));
    wire [63:0] norm_q = surd_sub(surd_add(F2, surd_add(G2, H2)), surd_add(FG, surd_add(GH, HF)));

    always @(*) begin
        assume(rst_n == 1'b1);

        // Constraint 1: Unit Sum (Identity case: F=1, G=0, H=0)
        // Fixed Point 16.16: 1.0 = 0x10000
        assume(sum_FGH == 64'h00000000_00010000);

        // Constraint 2: Unit Quadratic Norm
        assume(norm_q[63:32] == 32'h0);
        assume(norm_q[31:0] == 32'h10000);
    end

    // --- 4. The Indestructible Assertion ---
    
    always @(posedge clk) begin
        // Vd must be EXACTLY 1.0 if constraints are exact
        assert(det_M == 64'h00000000_00010000);
    end

`endif

endmodule
