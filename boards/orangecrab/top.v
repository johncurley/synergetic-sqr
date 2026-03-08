// OrangeCrab Top-Level Integration (v3.1.36)
// Target: Lattice ECP5
// Implementation: Universal Fractal Heart (61.44 kHz)

module orangecrab_top (
    input  wire clk_48mhz,
    input  wire btn_rst_n,
    output wire led_red,
    output wire led_green,
    output wire led_blue,
    output wire uart_tx,
    input  wire uart_rx
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(48000000)
    ) fractal_osc (
        .clk_in(clk_48mhz),
        .rst_n(btn_rst_n),
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core
    spu_core u_core (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. IO Bridge (UART Telemetry)
    spu_io_bridge #(
        .CLK_FREQ(61440)
    ) u_io (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .spu_reg_in(next_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led_red   = fault;
    assign led_green = clk_resonant;
    assign led_blue  = 1'b0;

endmodule
