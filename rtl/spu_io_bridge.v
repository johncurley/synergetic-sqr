// SPU-13 I/O Bridge (v3.1.8)
module spu_io_bridge (
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] spu_reg_in,
    input  wire         fault_detected,
    output wire [7:0]   led_status,
    output wire [7:0]   pmod_ja_out,
    output wire [3:0]   sw_control,
    input  wire         serial_rx,
    output wire         serial_tx
);
    assign led_status = spu_reg_in[7:0];
    assign pmod_ja_out = spu_reg_in[15:8];
    assign sw_control = 4'b0;
    assign serial_tx = serial_rx;
endmodule
