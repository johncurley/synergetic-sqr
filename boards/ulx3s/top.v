// ULX3S Top-Level Integration (v3.1.36)
// Target: Lattice ECP5
// Implementation: Universal Fractal Heart (61.44 kHz)

module ulx3s_top (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire [7:0] led,
    output wire ftdi_tdo, // UART TX
    input  wire ftdi_rxd  // UART RX
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(25000000)
    ) fractal_osc (
        .clk_in(clk_25mhz),
        .rst_n(btn[0]),
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core
    spu_core u_core (
        .clk(clk_resonant),
        .reset(~btn[0]),
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
        .reset(~btn[0]),
        .spu_reg_in(next_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(ftdi_rxd),
        .serial_tx(ftdi_tdo)
    );

    assign led[3:0] = bridge_leds;
    assign led[4]   = clk_resonant;
    assign led[7]   = fault;

endmodule
