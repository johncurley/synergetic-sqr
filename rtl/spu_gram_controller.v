// SPU-13 G-RAM Controller (v3.1.8)
module spu_gram_controller (
    input  wire         clk,
    input  wire         reset,
    input  wire         janus_bit,
    input  wire [31:0]  addr_in,
    output wire [31:0]  phys_addr_out,
    output wire [831:0] data_out,
    output wire         ready
);
    assign phys_addr_out = addr_in;
    assign data_out = 832'b0;
    assign ready = 1'b1;
endmodule
