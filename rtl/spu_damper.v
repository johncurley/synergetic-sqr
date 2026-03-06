// SPU-1 Rational Damper (v2.1.1)
// Implements Discrete Shell Contraction: x_out = (x_in >>> 1) + Permute_Sink
// Replaces transcendental Laplace decay with bit-exact A-Domain contraction.

module spu_damper (
    input  [255:0] q_in,
    output [255:0] q_out
);

    wire [255:0] scaled_q;
    
    // 1. Rational Scaling (Step-Down to nested shell)
    // Every lane magnitude is reduced by 50% bit-exactly.
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : damp_lanes
            wire signed [31:0] component = q_in[i*32 +: 32];
            // Arithmetic shift with 1-unit floor protection
            // If the value is 1 or -1, it snaps to 0.
            assign scaled_q[i*32 +: 32] = (component == 32'sd1 || component == -32'sd1) ? 32'sd0 : (component >>> 1);
        end
    endgenerate

    // 2. Permutational Sink (Thomson Prime-7 Flip)
    // Rotates the remaining energy into the 4D basis
    spu_permute sink (
        .q_in(scaled_q),
        .prime_phase(2'b11), // P7: Hyper-Flip
        .q_out(q_out)
    );

endmodule
