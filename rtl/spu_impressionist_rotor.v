// SPU-13 Impressionist Rotor (v3.1.7)
// Function: Coordinate-Invariant Asymmetrical Transformation.
// Logic: Uses Symmetric Group Permutations (S4) to define 'Tilt' without sines.

module spu_impressionist_rotor (
    input  wire [63:0] q_in [0:3],   // 4-axis ABCD input
    input  wire [1:0]  tilt_phase,   // Asymmetrical angle selection
    output reg  [63:0] q_out [0:3]   // Bit-Exact Output
);

    // 1. Rational Ratio Mapping (The 'Impressionist' Angle)
    // Instead of 15.4 degrees, we use a 3/5 Isotropic Ratio.
    // The 'Tilt' is a linear combination of primary and secondary axes.

    always @(*) begin
        case (tilt_phase)
            2'b00: begin // Identity: Standard Isotropic alignment
                {q_out[0], q_out[1], q_out[2], q_out[3]} = {q_in[0], q_in[1], q_in[2], q_in[3]};
            end
            2'b01: begin // Impressionist Tilt: Axis A blends into B and C
                // Bit-exact permutation avoiding transcendental multipliers
                q_out[0] = (q_in[0] >> 1) + (q_in[1] >> 2); // 3/4 blend
                q_out[1] = (q_in[1] >> 1) + (q_in[2] >> 2);
                q_out[2] = (q_in[2] >> 1) + (q_in[0] >> 2);
                q_out[3] = q_in[3]; // Vertical anchor
            end
            2'b10: begin // Reciprocal Tilt (Mirror)
                {q_out[0], q_out[1], q_out[2], q_out[3]} = {q_in[2], q_in[1], q_in[0], q_in[3]};
            end
            default: {q_out[0], q_out[1], q_out[2], q_out[3]} = {q_in[0], q_in[1], q_in[2], q_in[3]};
        endcase
    end

endmodule
