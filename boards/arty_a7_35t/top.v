// Arty A7-35T Top-Level Integration (v3.4.2)
// Target: Xilinx Artix-7
// Implementation: 13-Core Collective Manifold with Thalamic Integration.

module arty_a7_top (
    input  wire       clk_100mhz,
    input  wire       btn_rst_n,      
    input  wire       bias_in,        // Proprioceptive Antenna
    input  wire [11:0] adc_in,        // Metabolic Sense
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
    wire [127:0] strike_ripple;
    wire [15:0]  microwatts;
    wire         sip_active;
    wire [7:0]   bloom_intensity;
    wire         coherence_lock;
    wire [3:0]   q_mood;
    wire [2:0]   boot_phase;
    wire         lattice_fault;
    wire         henosis_pass;
    wire         wake_complete;
    
    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(100000000)
    ) fractal_osc (
        .clk_in(clk_100mhz), .rst_n(btn_rst_n), .en(sw[3]), 
        .bias_in(bias_in), .clk_laminar(clk_resonant), .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(btn_rst_n), .en(sw[3]),
        .handshake_done(1'b1), .identity_lock(1'b1),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Phyllotaxis Lattice (13-Core Manifold)
    spu_lattice_13 u_lattice (
        .clk(clk_resonant), .reset(~btn_rst_n), .opcode(sw[2:0]), 
        .prime_phase(sw[2:1]), .sign_flip(1'b0), .ext_in(832'b0),
        .strike_in(strike_ripple), .manifold_out(manifold_state), .lattice_fault(lattice_fault)
    );

    // 4. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant), .reset(~btn_rst_n), .boot_phase(boot_phase),
        .reg_in(manifold_state), .reg_out(reg_state), .henosis_active()
    );

    // 5. Metabolic Sense
    spu_metabolic_sense u_metabolic (
        .clk(clk_resonant), .reset(~btn_rst_n),
        .adc_raw(adc_in), .microwatts(microwatts), .sip_active(sip_active)
    );

    // 6. Thalamus (Consciousness Relay)
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(~btn_rst_n),
        .microwatts(microwatts), .synergy_idx(1'b1), .identity_lock(!lattice_fault),
        .bloom_intensity(bloom_intensity), .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 7. IO Bridge (Interactive Standard)
    spu_io_bridge #(
        .CLK_PHYS_HZ(100000000)
    ) u_io (
        .clk_phys(clk_100mhz), .clk_resonant(clk_resonant), .reset(~btn_rst_n),
        .spu_reg_in(reg_state), .microwatts(microwatts), .sip_active(sip_active),
        .strike_ripple(strike_ripple), .fault_detected(lattice_fault),
        .coherence_lock(coherence_lock), .led_status(led),
        .pmod_ja_out(pmod_ja), .sw_control(sw), .serial_rx(usb_uart_rx), .serial_tx(usb_uart_tx)
    );

endmodule
