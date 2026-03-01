// SPU-1 Prime-Axis Permutator (v2.0.33)
// Based on Thomson's 4D Prime Projection Conjecture v2.0
// Implements zero-latency basis shifts aligned with 5-cell symmetry.

module spu_permute (
    input [255:0] q_in,      // 4-axis Quadray [a,b,c,d]
    input [1:0] prime_phase, // 0=P1 (ID), 1=P3 (60deg), 2=P5 (120deg), 3=P7 (Flip)
    output reg [255:0] q_out
);

    // Quadray Lane Mapping (LSB to MSB):
    // q_in[63:0]   = Q1 (a)
    // q_in[127:64]  = Q2 (b)
    // q_in[191:128] = Q3 (c)
    // q_in[255:192] = Q4 (d)

    always @(*) begin
        case (prime_phase)
            // Prime 1: Identity (a, b, c, d)
            2'b00: q_out = q_in;                       
            
            // Prime 3: 60 deg Pin-A (a, d, b, c) 
            2'b01: q_out = {q_in[191:128], q_in[127:64], q_in[255:192], q_in[63:0]}; 
            
            // Prime 5: 120 deg Pin-A (a, c, d, b)
            2'b10: q_out = {q_in[127:64], q_in[255:192], q_in[191:128], q_in[63:0]}; 
            
            // Prime 7: Hyper-Flip (d, b, c, a) - 4th axis enters the fray
            2'b11: q_out = {q_in[63:0], q_in[127:64], q_in[191:128], q_in[255:192]}; 
        endcase
    end
endmodule
