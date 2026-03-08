// iCeSugar Full Manifold Realization (v3.3.13)
// Target: Lattice iCE40UP5K (iCeSugar Nano/Pro)
// Objective: Full SQR-Link with One-Second Stability Audit

module icesugar_full_manifold (
    input  wire clk_12mhz,    // Pin 35 (Physical Oscillator)
    input  wire rst_n,        // Pin 18 (Active-Low Reset)
    output wire led_red,      // Pin 39 (Fault/Failure)
    output wire led_green,    // Pin 40 (Resonance Lock)
    output wire led_blue,     // Pin 41 (Manifold Heartbeat)
    output wire uart_tx,      // Pin 10
    input  wire uart_rx,      // Pin 9
    output wire janus_pos,    // Pin 46
    output wire janus_neg     // Pin 47
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis_pass;
    wire         henosis_fail;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_n),
        .en(1'b1), // Always enabled for full manifold
        .clk_laminar(clk_resonant)
    );

    // 2. SPU-13 Core Manifold
    spu_core u_core (
        .clk(clk_resonant),
        .reset(!rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // Thomson Rotation Path
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 3. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(!rst_n),
        .reg_in(next_state),
        .pass(henosis_pass),
        .fail(henosis_fail)
    );

    // 4. Janus-Gate Differential Modulation
    assign janus_pos = next_state[0];
    assign janus_neg = ~next_state[0];

    // 5. IO Bridge (UART C&C)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz),
        .clk_resonant(clk_resonant),
        .reset(!rst_n),
        .spu_reg_in(next_state),
        .fault_detected(fault | henosis_fail),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    // 6. LED Status Mapping
    assign led_red   = fault | henosis_fail; // Red = Turbulence or Audit Failure
    assign led_green = henosis_pass;         // Green = Stability Audit Passed
    assign led_blue  = clk_resonant;         // Blue = Pulse awareness

endmodule
