// Arty A7-35T Top-Level Integration (v3.3.70)
// Target: Xilinx Artix-7
// Implementation: Automated Bowman Wake with 13-Core Collective Manifold

module arty_a7_top (
    input  wire       clk_100mhz,
    input  wire       btn_rst_n,      
    input  wire [3:0] sw,             
    output wire [3:0] led,            
    output wire [7:0] pmod_ja,
    input  wire       usb_uart_rx,
    output wire       usb_uart_tx
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire [831:0] manifold_state;
    wire [2:0]   boot_phase;
    wire         lattice_fault;
    wire         henosis_pass;
    wire         wake_complete;
    
    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(100000000)
    ) fractal_osc (
        .clk_in(clk_100mhz),
        .rst_n(btn_rst_n),
        .en(sw[3]), // Switch 3 acts as the Throttle
        .clk_laminar(clk_resonant)
    );

    // 2. The Bowman Sequencer: Automated Wake-Up
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(btn_rst_n),
        .en(sw[3]),
        .handshake_done(1'b1),
        .identity_lock(1'b1),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. SPU-13 Phyllotaxis Lattice (13 Interconnected Cores)
    spu_lattice_13 u_lattice (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .opcode(sw[2:0]),
        .prime_phase(sw[2:1]),
        .sign_flip(1'b0),
        .ext_in(832'b0),
        .manifold_out(manifold_state),
        .lattice_fault(lattice_fault)
    );

    // 4. Power Dispatcher (Laminar Logic)
    spu_laminar_power u_power (
        .clk(clk_resonant),
        .reset(~btn_rst_n),
        .boot_phase(boot_phase),
        .reg_in(manifold_state),
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
        .CLK_PHYS_HZ(100000000)
    ) u_io (
        .clk_phys(clk_100mhz),
        .clk_resonant(clk_resonant),
        .reset(~btn_rst_n),
        .spu_reg_in(reg_state),
        .fault_detected(lattice_fault),
        .led_status(led),
        .pmod_ja_out(pmod_ja),
        .sw_control(sw),
        .serial_rx(usb_uart_rx),
        .serial_tx(usb_uart_tx)
    );

endmodule
