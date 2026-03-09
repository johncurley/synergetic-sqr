// iCEBreaker Top-Level Integration (v3.4.2)
// Target: Lattice iCE40UP5K
// Implementation: Automated Bowman Wake & Thalamic Integration.

module icebreaker_top (
    input  wire clk_12mhz,
    input  wire btn_rst_n,
    input  wire bias_in,      // Proprioceptive Antenna
    input  wire [11:0] adc_in, // Metabolic Sense (External ADC)
    output wire led_red,
    output wire led_green,
    output wire uart_tx,
    input  wire uart_rx
);

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
    wire         identity_lock;

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz), .rst_n(btn_rst_n), .en(1'b1),
        .bias_in(bias_in), .clk_laminar(clk_resonant), .synergy_idx()
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(btn_rst_n), .en(1'b1),
        .handshake_done(1'b1), .identity_lock(identity_lock),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core
    spu_core u_core (
        .clk(clk_resonant), .reset(~btn_rst_n), .reg_curr(reg_state),
        .neighbors(3072'b0), .strike_in(strike_ripple), .opcode(3'b001),
        .prime_phase(2'b01), .sign_flip(1'b0), .reg_out(next_state),
        .fault_detected(fault)
    );

    // 4. Power Dispatcher
    spu_laminar_power u_power (
        .clk(clk_resonant), .reset(~btn_rst_n), .boot_phase(boot_phase),
        .reg_in(next_state), .reg_out(reg_state), .henosis_active()
    );

    // 5. Metabolic Sense
    spu_metabolic_sense u_metabolic (
        .clk(clk_resonant), .reset(~btn_rst_n),
        .adc_raw(adc_in), .microwatts(microwatts), .sip_active(sip_active)
    );

    // 6. Thalamus (Consciousness Relay)
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(~btn_rst_n),
        .microwatts(microwatts), .synergy_idx(1'b1), .identity_lock(!fault),
        .bloom_intensity(bloom_intensity), .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 7. IO Bridge (Interactive Standard)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz), .clk_resonant(clk_resonant), .reset(~btn_rst_n),
        .spu_reg_in(reg_state), .microwatts(microwatts), .sip_active(sip_active),
        .strike_ripple(strike_ripple), .fault_detected(fault),
        .coherence_lock(coherence_lock), .led_status(),
        .pmod_ja_out(), .sw_control(4'b0), .serial_rx(uart_rx), .serial_tx(uart_tx)
    );

    assign led_red   = fault | !sip_active;
    assign led_green = henosis_pass & wake_complete;

endmodule
