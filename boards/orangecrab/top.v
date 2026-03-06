// OrangeCrab Top-Level Integration (v3.1.10)
// Target: Lattice ECP5 (48MHz Internal Clock)

module orangecrab_top (
    input  wire clk_48mhz,
    input  wire btn_rst_n,
    output wire led_r, led_g, led_b,
    output wire uart_tx,
    input  wire uart_rx
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         resonance_lock;
    wire [3:0]   bridge_leds;

    spu_core u_core (
        .clk(clk_48mhz),
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
        .clk(clk_48mhz),
        .reset(~btn_rst_n),
        .reg_in(next_state),
        .pass(resonance_lock)
    );

    spu_io_bridge #(
        .CLK_FREQ(48000000)
    ) u_io (
        .clk(clk_48mhz),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led_r = bridge_leds[3];
    assign led_g = bridge_leds[2];
    assign led_b = bridge_leds[1];

endmodule
