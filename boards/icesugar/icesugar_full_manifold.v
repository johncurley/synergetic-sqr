// iCeSugar Full Manifold Realization (v3.3.70)
// Target: Lattice iCE40UP5K (iCeSugar Nano/Pro)
// Objective: Full 832-bit SQR-Link with Automated Bowman Wake.

module icesugar_full_manifold (
    input  wire clk_12mhz,    // Pin 35 (Physical Oscillator)
    input  wire rst_n,        // Pin 18 (Active-Low Reset)
    input  wire laminar_en,   // Pin 11 (Manual Throttle)
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
    wire [2:0]   boot_phase;
    wire         fault;
    wire         henosis_pass;
    wire         henosis_fail;
    wire         wake_complete;
    wire [3:0]   bridge_leds;
    wire         identity_lock;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_n),
        .en(laminar_en),
        .clk_laminar(clk_resonant)
    );

    // 2. The Bowman Sequencer: Automated Wake-Up
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(rst_n),
        .en(laminar_en),
        .handshake_done(1'b1), // Simplified for Phase 1.2
        .identity_lock(1'b1),  // Assuming lock for pilot
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core Manifold
    spu_core u_core (
        .clk(clk_resonant),
        .reset(!rst_n),
        .reg_curr(reg_state),
        .neighbors(3072'b0),
        .opcode(3'b001),      
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(next_state),
        .fault_detected(fault)
    );

    // 4. Power Dispatcher (Laminar Logic)
    // Orchestrates the gradual introduction of energy to the manifold.
    spu_laminar_power u_power (
        .clk(clk_resonant),
        .reset(!rst_n),
        .boot_phase(boot_phase),
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active()
    );

    // 5. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(!rst_n),
        .reg_in(reg_state),
        .pass(henosis_pass),
        .fail(henosis_fail)
    );

    // 6. Janus-Gate Differential Modulation
    assign janus_pos = reg_state[0];
    assign janus_neg = ~reg_state[0];

    // 7. IO Bridge (UART C&C)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz),
        .clk_resonant(clk_resonant),
        .reset(!rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault | henosis_fail),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    // 8. LED Status Mapping
    assign led_red   = fault | henosis_fail; 
    assign led_green = henosis_pass;         
    assign led_blue  = clk_resonant & wake_complete;

endmodule
