// ULX3S Harmonic Manifold (v1.0)
// Target: Lattice ECP5-85k
// Implementation: 4-Core Harmonic Subset with Thalamic Homeostasis.

module ulx3s_top (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    input  wire bias_in,
    input  wire [11:0] adc_in,
    output wire [7:0] led,
    output wire ftdi_tdo, // UART TX
    input  wire ftdi_rxd  // UART RX
);

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] manifold_state;
    wire [127:0] strike_ripple;
    wire [15:0]  microwatts;
    wire [7:0]   bloom_intensity;
    wire [3:0]   freq_bias;
    wire         coherence_lock;
    wire [3:0]   q_mood;
    wire [2:0]   boot_phase;
    wire         lattice_fault;
    wire         wake_complete;
    wire [3:0]   bridge_leds;

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(25000000)
    ) fractal_osc (
        .clk_in(clk_25mhz), .rst_n(btn[0]), .en(1'b1),
        .bias_in(bias_in), .freq_bias(freq_bias),
        .clk_laminar(clk_resonant), .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(btn[0]), .en(1'b1),
        .handshake_done(1'b1), .identity_lock(1'b1),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Harmonic Lattice (4-Core Subset)
    spu_lattice_4 u_lattice (
        .clk(clk_resonant), .reset(~btn[0]), .opcode(3'b001), 
        .prime_phase(2'b01), .sign_flip(1'b0), .ext_in(832'b0),
        .strike_in(strike_ripple), .manifold_out(manifold_state), .lattice_fault(lattice_fault)
    );

    // 4. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant), .reset(~btn[0]), .boot_phase(boot_phase),
        .bloom_intensity(bloom_intensity), .reg_in(manifold_state), 
        .reg_out(reg_state), .henosis_active()
    );

    // 5. Thalamus
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(~btn[0]),
        .adc_raw(adc_in), .synergy_idx(1'b1), .identity_lock(!lattice_fault),
        .microwatts(microwatts), .bloom_intensity(bloom_intensity), .freq_bias(freq_bias),
        .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 6. IO Bridge
    spu_io_bridge #(
        .CLK_PHYS_HZ(25000000)
    ) u_io (
        .clk_phys(clk_25mhz), .clk_resonant(clk_resonant), .reset(~btn[0]),
        .spu_reg_in(reg_state), .microwatts(microwatts), .sip_active(microwatts < 100),
        .strike_ripple(strike_ripple), .fault_detected(lattice_fault),
        .coherence_lock(coherence_lock), .led_status(bridge_leds),
        .pmod_ja_out(), .sw_control(4'b0), .serial_rx(ftdi_rxd), .serial_tx(ftdi_tdo)
    );

    assign led[3:0] = bridge_leds;
    assign led[4]   = clk_resonant;
    assign led[5]   = wake_complete;
    assign led[6]   = (microwatts < 100); 
    assign led[7]   = lattice_fault;

endmodule
