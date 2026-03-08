// iCeSugar Top-Level Integration (v3.1.32)
// Target: Lattice iCE40UP5K (iCeSugar Nano/Pro)
// Objective: Physical realization of the SPU-13 Manifold

module icesugar_full_manifold (
    input  wire clk_resonant, // Pin 35 (Global Clock)
    output wire led_red,      // Pin 39
    output wire led_green,    // Pin 40
    output wire led_blue,     // Pin 41
    output wire uart_tx,      // Pin 10
    input  wire uart_rx,      // Pin 9
    output wire janus_pos,    // Pin 46
    output wire janus_neg     // Pin 47
);

    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire         fault;
    wire         henosis;
    wire [3:0]   bridge_leds;
    wire         laminar_sync;

    // 1. SPU-13 Core Manifold
    spu_core u_core (
        .clk(clk_resonant),
        .reset(1'b0), // iCeSugar usually doesn't have a dedicated reset button, using power-on
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      // Thomson Rotation Path
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 2. Janus-Gate Differential Modulation
    // This implements the Chiral Inversion at the physical IO level
    assign janus_pos = next_state[0];
    assign janus_neg = ~next_state[0];

    // 3. IO Bridge (UART C&C)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000) // Default iCeSugar oscillator is 12MHz
    ) u_io (
        .clk_phys(clk_resonant), // Capturing at resonant heartbeat for Phase 1
        .clk_resonant(clk_resonant),
        .reset(1'b0),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    // 4. LED Status Mapping
    assign led_red   = fault;          // Red = Turbulence Detected
    assign led_green = bridge_leds[1]; // Green = Resonance Lock
    assign led_blue  = clk_resonant;   // Blue = Phase Awareness (Visual heartbeat)

endmodule
