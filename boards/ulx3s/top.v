// ULX3S Top-Level Integration (v3.1.10)
// Target: Lattice ECP5 (25MHz Internal Clock)

module ulx3s_top (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire [7:0] led,
    output wire ftdi_tx,
    input  wire ftdi_rx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         henosis;
    wire         fault;

    spu_core u_core (
        .clk(clk_25mhz), .reset(btn[0]),
        .reg_curr(reg_state), .neighbors(3072'b0),
        .opcode(3'b001), .prime_phase(2'b01), .sign_flip(1'b0),
        .reg_out(next_state), .fault_detected(fault)
    );

    spu_self_test u_test (
        .clk(clk_25mhz), .reset(btn[0]),
        .reg_in(next_state), .pass(henosis)
    );

    spu_io_bridge #(
        .CLK_FREQ(25000000)
    ) u_io (
        .clk(clk_25mhz),
        .reset(btn[0]),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(led[3:0]),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(ftdi_rx),
        .serial_tx(ftdi_tx)
    );

    assign led[7:4] = reg_state[3:0];

endmodule
