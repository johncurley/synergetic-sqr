// SPU-1 Prime-Axis Permutator (v2.9.13 Optimized)
// Implements 4D basis shifts as Zero-Gate wire-swaps.
// Optimized with XOR Sign-Flips and Pipelined Output for >400MHz.

module spu_permute (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] q_in,        // 4 Lanes x 64-bit (a, b)
    input  wire [1:0]   prime_phase, // Rotation phase control
    input  wire         sign_flip,   // XOR negation trigger
    output reg  [255:0] q_out        // Pipelined Output
);

    // 1. Lane Extraction
    wire [63:0] q1 = q_in[63:0];
    wire [63:0] q2 = q_in[127:64];
    wire [63:0] q3 = q_in[191:128];
    wire [63:0] q4 = q_in[255:192];

    // 2. Sign Negation (Zero-Cost XOR)
    // Flips polarity if sign_flip is active
    wire [63:0] s1 = sign_flip ? ~q1 : q1;
    wire [63:0] s2 = sign_flip ? ~q2 : q2;
    wire [63:0] s3 = sign_flip ? ~q3 : q3;
    wire [63:0] s4 = sign_flip ? ~q4 : q4;

    // 3. Combinational Permutation Mapping
    reg [255:0] perm_next;
    always @(*) begin
        case (prime_phase)
            2'b01:   perm_next = {s1, s4, s3, s2}; // P3 (60°)
            2'b10:   perm_next = {s2, s1, s4, s3}; // P5 (120°)
            2'b11:   perm_next = {s4, s3, s2, s1}; // P7 (Hyper-Flip)
            default: perm_next = {s4, s3, s2, s1}; // P1 (Identity)
        endcase
    end

    // 4. Pipelined Registration (Timing Closure)
    always @(posedge clk or posedge reset) begin
        if (reset) q_out <= 256'b0;
        else       q_out <= perm_next;
    end

endmodule
