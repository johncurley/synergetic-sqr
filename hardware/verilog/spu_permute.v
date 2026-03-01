// SPU-1 Prime-Axis Permutator (v2.0.35)
// Implements basis shifts aligned with Thomson's 4D Prime Projection.
// Uses named slices to ensure 100% architectural clarity.

module spu_permute (
    input  [255:0] q_in,        // 4-axis Quadray packed as {d, c, b, a}
    input  [1:0]   prime_phase, // 0=P1, 1=P3, 2=P5, 3=P7
    output reg [255:0] q_out
);

    // Named Lane Extractions (64-bit lanes)
    // Endianness: q_in[63:0] is 'a', q_in[255:192] is 'd'
    wire [63:0] a = q_in[63:0];
    wire [127:64] b = q_in[127:64];
    wire [191:128] c = q_in[191:128];
    wire [255:192] d = q_in[255:192];

    always @(*) begin
        case (prime_phase)
            // Prime 1: Identity (a, b, c, d)
            2'd0: q_out = {d, c, b, a}; 
            
            // Prime 3: 60° (b, c, a, d)
            // Mapping: out[0]=b, out[1]=c, out[2]=a, out[3]=d
            2'd1: q_out = {d, a, c, b}; 
            
            // Prime 5: 120° (c, a, b, d)
            // Mapping: out[0]=c, out[1]=a, out[2]=b, out[3]=d
            2'd2: q_out = {d, b, a, c}; 
            
            // Prime 7: Hyper-Flip (d, b, c, a)
            // Mapping: out[0]=d, out[1]=b, out[2]=c, out[3]=a
            2'd3: q_out = {a, c, b, d}; 
            
            default: q_out = {d, c, b, a};
        endcase
    end
endmodule
