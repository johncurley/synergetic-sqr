// iCeSugar Full Manifold Realization (v3.4.19)
// Target: Lattice iCE40UP5K (iCeSugar Nano/Pro)
// Objective: Full 832-bit SQR-Link with Thalamic sensory integration.
// Interaction: Dynamic Bloom self-regulation enabled.

module icesugar_full_manifold (
    input  wire clk_12mhz,    // Pin 35 (Physical Oscillator)
    input  wire rst_n,        // Pin 18 (Active-Low Reset)
    input  wire laminar_en,   // Pin 11 (Manual Throttle)
    input  wire bias_in,      // Pin 12 (Nervous Antenna)
    input  wire [11:0] adc_in, // Pin 13 (Metabolic Sense)
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
    wire [127:0] strike_ripple;
    wire [15:0]  microwatts;
    wire [7:0]   bloom_intensity;
    wire         coherence_lock;
    wire [3:0]   q_mood;
    wire [2:0]   boot_phase;
    wire         fault;
    wire         henosis_pass;
    wire         henosis_fail;
    wire         wake_complete;
    wire         identity_lock;
    wire         synergy_idx;

    // 1. The Fractal Heart
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz), .rst_n(rst_n), .en(laminar_en),
        .bias_in(bias_in), .clk_laminar(clk_resonant), .synergy_idx(synergy_idx)
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(rst_n), .en(laminar_en),
        .handshake_done(1'b1), .identity_lock(identity_lock),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core Manifold
    spu_core u_core (
        .clk(clk_resonant), .reset(!rst_n), .reg_curr(reg_state),
        .neighbors(3072'b0), .strike_in(strike_ripple), .opcode(3'b001),      
        .prime_phase(2'b01), .sign_flip(1'b0), .reg_out(next_state),
        .fault_detected(fault)
    );

    // 4. Power Dispatcher (Laminar Logic)
    // Dynamic Bloom scaling based on Thalamic intensity.
    spu_laminar_power u_power (
        .clk(clk_resonant), .reset(!rst_n), .boot_phase(boot_phase),
        .bloom_intensity(bloom_intensity), .reg_in(next_state), 
        .reg_out(reg_state), .henosis_active()
    );

    // 5. Thalamus v2 (Consciousness Relay)
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(!rst_n),
        .adc_raw(adc_in), .synergy_idx(synergy_idx), .identity_lock(!fault),
        .microwatts(microwatts), .bloom_intensity(bloom_intensity), 
        .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 6. One-Second Stability Audit
    spu_self_test u_audit (
        .clk(clk_resonant), .reset(!rst_n), .reg_in(reg_state),
        .pass(henosis_pass), .fail(henosis_fail)
    );

    // 7. IO Bridge
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz), .clk_resonant(clk_resonant), .reset(!rst_n),
        .spu_reg_in(reg_state), .microwatts(microwatts), .sip_active(microwatts < 100),
        .strike_ripple(strike_ripple), .fault_detected(fault | henosis_fail),
        .coherence_lock(coherence_lock), .led_status(),
        .pmod_ja_out(), .sw_control(4'b0), .serial_rx(uart_rx), .serial_tx(uart_tx)
    );

    // 8. Janus-Gate Differential Modulation
    assign janus_pos = reg_state[0];
    assign janus_neg = ~reg_state[0];

    // 9. LED Status Mapping
    assign led_red   = fault | henosis_fail | (microwatts >= 100); 
    assign led_green = henosis_pass & wake_complete;
    assign led_blue  = clk_resonant & q_mood[2];

endmodule
