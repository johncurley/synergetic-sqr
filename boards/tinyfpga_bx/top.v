// TinyFPGA BX Top-Level Integration (v3.4.5)
// Target: Lattice iCE40LP8K
// Implementation: Automated Bowman Wake & Interactive Resonance.

module tinyfpga_bx_top (
    input  wire clk, // 16MHz
    input  wire bias_in, // Proprioceptive Antenna
    input  wire [11:0] adc_in, // Metabolic Sense
    output wire pin_led,
    output wire usb_p,
    output wire usb_n,
    output wire usb_pu,
    output wire uart_tx,
    input  wire uart_rx
);

    // Disable USB
    assign usb_p = 1'b0;
    assign usb_n = 1'b0;
    assign usb_pu = 1'b0;

    wire clk_resonant;
    wire [831:0] reg_state;
    wire [831:0] next_state;
    wire [127:0] strike_ripple;
    wire [15:0]  microwatts;
    wire         sip_active;
    wire [7:0]   bloom_intensity;
    wire         coherence_lock;
    wire [3:0]   q_mood;
    wire [2:0]   boot_phase;
    wire         fault;
    wire         henosis_pass;
    wire         wake_complete;

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(16000000)
    ) fractal_osc (
        .clk_in(clk), .rst_n(1'b1), .en(1'b1),
        .bias_in(bias_in), .clk_laminar(clk_resonant), .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(1'b1), .en(1'b1),
        .handshake_done(1'b1), .identity_lock(1'b1),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core
    spu_core u_core (
        .clk(clk_resonant), .reset(1'b0), .reg_curr(reg_state),
        .neighbors(3072'b0), .strike_in(strike_ripple), .opcode(3'b001),
        .prime_phase(2'b01), .sign_flip(1'b0), .reg_out(next_state),
        .fault_detected(fault)
    );

    // 4. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant), .reset(1'b0), .boot_phase(boot_phase),
        .reg_in(next_state), .reg_out(reg_state), .henosis_active()
    );

    // 5. Thalamus v2 (Central Sensory Relay)
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(1'b0),
        .adc_raw(adc_in), .synergy_idx(1'b1), .identity_lock(!fault),
        .microwatts(microwatts), .bloom_intensity(bloom_intensity), 
        .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 6. IO Bridge (Interactive Standard)
    spu_io_bridge #(
        .CLK_PHYS_HZ(16000000)
    ) u_io (
        .clk_phys(clk), .clk_resonant(clk_resonant), .reset(1'b0),
        .spu_reg_in(reg_state), .microwatts(microwatts), .sip_active(microwatts < 100),
        .strike_ripple(strike_ripple), .fault_detected(fault),
        .coherence_lock(coherence_lock), .led_status(),
        .pmod_ja_out(), .sw_control(4'b0), .serial_rx(uart_rx), .serial_tx(uart_tx)
    );

    assign pin_led = henosis_pass & wake_complete & (microwatts < 100);

endmodule
