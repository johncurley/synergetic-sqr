// SPU-13: Quadrance (Q) Calculator
// Q = (a^2 + b^2 + c^2 + d^2) / 2
// Zero Square Roots. Zero Floating Point.

module quadrance_calc (
    input  wire [23:0] a, b, c, d,
    output wire [47:0] q_out // Double width for the square
);
    // Separate multipliers for each axis
    // This is the "Asymmetrical" Sip in action
    wire [47:0] sq_a = a * a;
    wire [47:0] sq_b = b * b;
    wire [47:0] sq_c = c * c;
    wire [47:0] sq_d = d * d;

    // Summing them up through the Asymmetrical Adder logic
    assign q_out = (sq_a + sq_b + sq_c + sq_d) >> 1; // Divide by 2 (Bit-shift)
endmodule
