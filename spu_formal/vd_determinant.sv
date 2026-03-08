// SPU-13 Formal Verification: Vd Determinant Invariant (v3.1.29)
// Field: Q(sqrt(3))
// Invariant: det(M) = F^3 + G^3 + H^3 - 3FGH = 1.0

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
        reg signed [63:0] res_i, res_s;
        begin
            i1 = a[31:0]; s1 = a[63:32];
            i2 = b[31:0]; s2 = b[63:32];
            
            // Rule: (i1*i2 + 3*s1*s2) + (i1*s2 + s1*i2)sqrt(3)
            res_i = (64'(i1) * i2) + (3 * (64'(s1) * s2));
            res_s = (64'(i1) * s2) + (64'(s1) * i2);
            
            surd_mul = {res_s[31:0], res_i[31:0]};
        end
    endfunction

    // --- 2. Determinant Components ---
    
    wire [63:0] F2 = surd_mul(F, F);
    wire [63:0] F3 = surd_mul(F2, F);
    
    wire [63:0] G2 = surd_mul(G, G);
    wire [63:0] G3 = surd_mul(G2, G);
    
    wire [63:0] H2 = surd_mul(H, H);
    wire [63:0] H3 = surd_mul(H2, H);
    
    wire [63:0] FG  = surd_mul(F, G);
    wire [63:0] FGH = surd_mul(FG, H);
    
    // 3*FGH
    wire [63:0] three_FGH = {FGH[63:32] * 3, FGH[31:0] * 3};

    // det(M) = F^3 + G^3 + H^3 - 3FGH
    wire [63:0] det_M_sum = {F3[63:32] + G3[63:32] + H3[63:32] - three_FGH[63:32], 
                             F3[31:0]  + G3[31:0]  + H3[31:0]  - three_FGH[31:0]};

    // --- 3. The Indestructible Assertion ---
    
    always @(posedge clk) begin
        if (rst_n) begin
            // Vd must be EXACTLY 1.0 (Integer component = 1, Surd component = 0)
            assert(det_M_sum == 64'h00000000_00000001);
        end
    end

`endif

endmodule
