// SPU-13 Impressionist Rotor (v3.1.8)
module spu_impressionist_rotor (
    input  wire [255:0] q_in,   // Packed 4-axis ABCD input
    input  wire [1:0]   tilt_phase,
    output reg  [255:0] q_out   // Packed Output
);
    wire [63:0] a = q_in[63:0];
    wire [63:0] b = q_in[127:64];
    wire [63:0] c = q_in[191:128];
    wire [63:0] d = q_in[255:192];

    always @(*) begin
        case (tilt_phase)
            2'b01: begin 
                q_out[63:0]   = (a >> 1) + (b >> 2);
                q_out[127:64] = (b >> 1) + (c >> 2);
                q_out[191:128]= (c >> 1) + (a >> 2);
                q_out[255:192]= d;
            end
            default: q_out = q_in;
        endcase
    end
endmodule
