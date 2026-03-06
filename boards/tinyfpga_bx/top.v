// TinyFPGA BX Top-Level Integration (v3.1.10)
// Target: Lattice iCE40LP8K (16MHz Internal Clock)

module tinyfpga_bx_top (
    input  wire clk_16mhz,
    output wire led,          
    output wire usb_tx,
    input  wire usb_rx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         henosis;
    wire         fault;

    spu_core u_core (
        .clk(clk_16mhz), .reset(1'b0),
        .reg_curr(reg_state), .neighbors(3072'b0),
        .opcode(3'b001), .prime_phase(2'b01), .sign_flip(1'b0),
        .reg_out(next_state), .fault_detected(fault)
    );

    spu_self_test u_test (
        .clk(clk_16mhz), .reset(1'b0),
        .reg_in(next_state), .pass(henosis)
    );

    spu_io_bridge #(
        .CLK_FREQ(16000000)
    ) u_io (
        .clk(clk_16mhz),
        .reset(1'b0),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(led),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(usb_rx),
        .serial_tx(usb_tx)
    );

endmodule
