// ULX3S Top-Level Integration (v3.3.91)
// Target: Lattice ECP5-85k
// Implementation: 13-Core Collective Manifold with Interactive Resonance.

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
    wire [831:0] manifold_state;
    wire [127:0] strike_ripple;
    wire [2:0]   boot_phase;
    wire         lattice_fault;
    wire         henosis_pass;
    wire         wake_complete;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(25000000)
    ) fractal_osc (
        .clk_in(clk_25mhz),
        .rst_n(btn[0]),
        .en(1'b1),
        .bias_in(1'b0),
        .clk_laminar(clk_resonant),
        .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(btn[0]),
        .en(1'b1),
        .handshake_done(1'b1),
        .identity_lock(1'b1),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. SPU-13 Phyllotaxis Lattice (13-Core Manifold)
    spu_lattice_13 u_lattice (
        .clk(clk_resonant),
        .reset(~btn[0]),
        .opcode(3'b001), 
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .ext_in(832'b0),
        .strike_in(strike_ripple),
        .manifold_out(manifold_state),
        .lattice_fault(lattice_fault)
    );

    // 4. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant),
        .reset(~btn[0]),
        .boot_phase(boot_phase),
        .reg_in(manifold_state),
        .reg_out(reg_state),
        .henosis_active()
    );

    // 5. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(~btn[0]),
        .reg_in(reg_state),
        .pass(henosis_pass),
        .fail()
    );

    // 6. IO Bridge (Interactive Standard)
    spu_io_bridge #(
        .CLK_PHYS_HZ(25000000)
    ) u_io (
        .clk_phys(clk_25mhz),
        .clk_resonant(clk_resonant),
        .reset(~btn[0]),
        .spu_reg_in(reg_state),
        .strike_ripple(strike_ripple),
        .fault_detected(lattice_fault),
        .coherence_lock(1'b1),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(4'b0),
        .serial_rx(ftdi_rxd),
        .serial_tx(ftdi_tdo)
    );

    assign led[3:0] = bridge_leds;
    assign led[4]   = clk_resonant;
    assign led[5]   = henosis_pass & wake_complete;
    assign led[7]   = lattice_fault;

endmodule
