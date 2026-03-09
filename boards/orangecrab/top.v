// OrangeCrab Top-Level Integration (v3.3.74)
// Target: Lattice ECP5
// Implementation: 13-Core Collective Phyllotaxis Lattice

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
    wire [831:0] manifold_state;
    wire         lattice_fault;
    wire         henosis_pass;
    wire         wake_complete;
    wire [2:0]   boot_phase;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(48000000)
    ) fractal_osc (
        .clk_in(clk_48mhz),
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

    // 3. SPU-13 Phyllotaxis Lattice (13 Interconnected Cores)
    spu_lattice_13 u_lattice (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .opcode(3'b001), // Default: SPERM_X4
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .ext_in(832'b0),
        .manifold_out(manifold_state),
        .lattice_fault(lattice_fault)
    );

    // 4. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .reg_in(manifold_state),
        .pass(henosis_pass),
        .fail()
    );

    // 5. IO Bridge (UART Telemetry)
    spu_io_bridge #(
        .CLK_PHYS_HZ(48000000)
    ) u_io (
        .clk_phys(clk_48mhz),
        .clk_resonant(clk_resonant),
        .reset(~btn_rst_n),
        .spu_reg_in(manifold_state),
        .fault_detected(lattice_fault),
        .led_status(bridge_leds),
        .pmod_ja_out(),
        .sw_control(),
        .serial_rx(uart_rx),
        .serial_tx(uart_tx)
    );

    assign led_red   = lattice_fault;
    assign led_green = henosis_pass & wake_complete;
    assign led_blue  = clk_resonant;

endmodule
