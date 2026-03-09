// iCEBreaker Top-Level Integration (v3.3.71)
// Target: Lattice iCE40UP5K
// Implementation: Automated Bowman Wake with Expanded ISA

module icebreaker_top (
    input  wire clk_12mhz,
    input  wire btn_rst_n,
    output wire led_red,
    output wire led_green,
    output wire uart_tx,
    input  wire uart_rx
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire [2:0]   boot_phase;
    wire         fault;
    wire         henosis_pass;
    wire         wake_complete;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart: Sierpiński Oscillator
    // Using led_green as a temporary throttle for iCEBreaker bring-up
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(btn_rst_n),
        .en(1'b1), 
        .clk_laminar(clk_resonant)
    );

    // 2. The Bowman Sequencer: Automated Wake-Up
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(btn_rst_n),
        .en(1'b1),
        .handshake_done(1'b1),
        .identity_lock(1'b1),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core Manifold (Expanded ISA)
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

    // 4. Power Dispatcher (Laminar Logic)
    spu_laminar_power u_power (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .boot_phase(boot_phase),
        .reg_in(next_state),
        .reg_out(reg_state),
        .henosis_active()
    );

    // 5. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .reg_in(reg_state),
        .pass(henosis_pass),
        .fail()
    );

    // 6. IO Bridge (UART Telemetry)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz),
        .clk_resonant(clk_resonant),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led_red   = fault;
    assign led_green = henosis_pass & wake_complete;

endmodule
