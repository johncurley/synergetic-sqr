// SPU-13: Spread Rotor Module (Rational Logic)
// Optimized for iCE40UP5K (iCeSugar)
// Implementation: Bit-Exact Rational Rotation via t-parameter

module spread_rotor (
    input  wire [11:0] spread_idx, // 4096 Discrete Steps of "Liquid"
    input  wire [23:0] vec_in_A, vec_in_B, vec_in_C, vec_in_D,
    output reg  [23:0] vec_out_A, vec_out_B, vec_out_C, vec_out_D
);

    // Rational LUT for Spread Constants
    // These store the (1-t^2) and (2t) components scaled by (1+t^2)
    reg [23:0] lut_cos [0:4095]; 
    reg [23:0] lut_sin [0:4095];
    reg [23:0] lut_den [0:4095];

    initial begin
        $readmemh("rotor_cos.hex", lut_cos);
        $readmemh("rotor_sin.hex", lut_sin);
        $readmemh("rotor_den.hex", lut_den);
    end

    // The Sovereign Rotation Formula
    // Based on Parametric Rational Trigonometry:
    // V_out_A = (V_in_A * cos - V_in_B * sin) / den
    // V_out_B = (V_in_A * sin + V_in_B * cos) / den
    
    always @(*) begin
        if (lut_den[spread_idx] != 0) begin
            // Axis A/B Plane Rotation
            vec_out_A = (vec_in_A * lut_cos[spread_idx] - vec_in_B * lut_sin[spread_idx]) / lut_den[spread_idx];
            vec_out_B = (vec_in_A * lut_sin[spread_idx] + vec_in_B * lut_cos[spread_idx]) / lut_den[spread_idx];
            
            // Axis C/D Plane Rotation (Complementary)
            vec_out_C = (vec_in_C * lut_cos[spread_idx] - vec_in_D * lut_sin[spread_idx]) / lut_den[spread_idx];
            vec_out_D = (vec_in_C * lut_sin[spread_idx] + vec_in_D * lut_cos[spread_idx]) / lut_den[spread_idx];
        end else begin
            // Fallback to Identity
            vec_out_A = vec_in_A;
            vec_out_B = vec_in_B;
            vec_out_C = vec_in_C;
            vec_out_D = vec_in_D;
        end
    end

endmodule
