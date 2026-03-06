// iCEBreaker Top-Level Integration (v3.1.10)
// Target: Lattice iCE40UP5K (12MHz Internal Clock)

module icebreaker_top (
    input  wire clk_12mhz,
    input  wire btn_rst_n,
    output wire led_red,
    output wire led_green,
    output wire uart_tx,
    input  wire uart_rx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis;
    wire [3:0]   bridge_leds;

    spu_core u_core (
        .clk(clk_12mhz),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // SPERM_X4
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    spu_self_test u_test (
        .clk(clk_12mhz),
        .reset(~btn_rst_n),
        .reg_in(next_state),
        .pass(henosis)
    );

    spu_io_bridge #(
        .CLK_FREQ(12000000)
    ) u_io (
        .clk(clk_12mhz),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led_red   = bridge_leds[3];
    assign led_green = bridge_leds[1];

endmodule
