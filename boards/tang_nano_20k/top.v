// Tang Nano 20k Top-Level Integration (v3.3.95)
// Target: Gowin GW2A-18C
// Implementation: Automated Bowman Wake with 13-Core Collective Manifold.

module tang_nano_20k_top (
    input  wire sys_clk, // 27MHz
    input  wire sys_rst_n,
    input  wire bias_in, // Proprioceptive Antenna
    output wire [5:0] led,
    output wire uart_tx,
    input  wire uart_rx
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

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(27000000)
    ) fractal_osc (
        .clk_in(sys_clk),
        .rst_n(sys_rst_n),
        .en(1'b1),
        .bias_in(bias_in),
        .clk_laminar(clk_resonant),
        .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(sys_rst_n),
        .en(1'b1),
        .handshake_done(1'b1),
        .identity_lock(1'b1),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. SPU-13 Phyllotaxis Lattice (13-Core Manifold)
    spu_lattice_13 u_lattice (
        .clk(clk_resonant),
        .reset(~sys_rst_n),
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
        .reset(~sys_rst_n),
        .boot_phase(boot_phase),
        .reg_in(manifold_state),
        .reg_out(reg_state),
        .henosis_active()
    );

    // 5. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(~sys_rst_n),
        .reg_in(reg_state),
        .pass(henosis_pass),
        .fail()
    );

    // 6. IO Bridge
    spu_io_bridge #(
        .CLK_PHYS_HZ(27000000)
    ) u_io (
        .clk_phys(sys_clk),
        .clk_resonant(clk_resonant),
        .reset(~sys_rst_n),
        .spu_reg_in(reg_state),
        .strike_ripple(strike_ripple),
        .fault_detected(lattice_fault),
        .coherence_lock(1'b1),
        .led_status(led[3:0]),
        .pmod_ja_out(),
        .sw_control(4'b0),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led[4] = clk_resonant;
    assign led[5] = henosis_pass & wake_complete;

endmodule
