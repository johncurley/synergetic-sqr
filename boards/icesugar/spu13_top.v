// SPU-13 TOP-LEVEL REIFICATION CORE (v3.4.25)
// Phase 1.1: Polarity Corrected & Enable-Gated
// Wake: Bowman Boot Sequence Automated.
// Sensory: Metabolic, Proprioceptive, and Viscosity (Liquid Flow) Integration.

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    input wire laminar_en,   // The 'Throttle' (High to Enable Flow) (Pin 11)
    input wire bias_in,      // Proprioceptive Entry (Pin 12)
    input wire [11:0] adc_in, // Metabolic Sense (Pin 13 - Header)
    
    // Electromagnetic Manifold
    output wire vector_A,    // Inductive Entry (Pin 46)
    output wire vector_B,    // Resonant Return (Pin 47)
    
    // Janus Status Display
    output wire led_sat_red, // Absence of the One / Identity Breach
    output wire led_sat_grn, // The One is Present (Laminar Lock)
    output wire led_sat_blu  // Searching / Handshake Active
);

    wire clk_resonant;
    wire janus_state;
    wire coherence_lock;
    wire identity_lock;
    wire phase_correct;
    wire synergy_idx;
    wire sonic_handshake;
    wire boot_done;
    wire [2:0] boot_phase;
    wire wake_complete;
    wire [127:0] strike_ripple;
    wire [15:0] microwatts;
    wire [7:0]  laminar_flow_index;
    wire [7:0]  bloom_intensity;
    wire [3:0]  freq_bias;
    wire [3:0]  q_mood;
    wire [63:0] h_seed;
    wire [831:0] manifold_out;

    // 1. The Fractal Heart: Regulated by Thalamic Bias
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz), .rst_n(rst_n), .en(laminar_en), 
        .bias_in(bias_in), .freq_bias(freq_bias),
        .clk_laminar(clk_resonant), .synergy_idx(synergy_idx)
    );

    // 2. The Bowman Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant), .rst_n(rst_n), .en(laminar_en),
        .handshake_done(boot_done), .identity_lock(identity_lock),
        .boot_phase(boot_phase), .wake_complete(wake_complete)
    );

    // 3. SPU-13 Core Lattice (The 13-axis Manifold)
    spu_lattice_13 u_manifold (
        .clk(clk_resonant), .reset(!rst_n), .opcode(3'b001), 
        .prime_phase(2'b01), .sign_flip(1'b0), .ext_in({768'b0, h_seed}),
        .strike_in(strike_ripple), .manifold_out(manifold_out), .lattice_fault()
    );

    // 4. Viscosity Monitor (Liquid Flow Sense)
    spu_viscosity_monitor u_viscosity (
        .clk(clk_resonant), .reset(!rst_n),
        .abcd_vector(manifold_out[127:0]),
        .laminar_flow_index(laminar_flow_index)
    );

    // 5. Thalamus v3 (Central Sensory Relay)
    spu_thalamus u_thalamus (
        .clk_resonant(clk_resonant), .reset(!rst_n),
        .adc_raw(adc_in), .synergy_idx(synergy_idx), .identity_lock(identity_lock),
        .laminar_flow_index(laminar_flow_index),
        .microwatts(microwatts), .bloom_intensity(bloom_intensity), .freq_bias(freq_bias),
        .coherence_lock(coherence_lock), .q_vec(q_mood)
    );

    // 6. The Harmonic Handshake
    spu_harmonic_handshake u_sonic (
        .clk_resonant(clk_resonant), .rst_n(rst_n),
        .en(laminar_en & (boot_phase == 3'b001)),
        .tone_out(sonic_handshake), .tone_id(), .handshake_done(boot_done)
    );

    // 7. Identity Gate
    spu_identity_monad u_identity (
        .clk(clk_resonant), .current_quadrance(64'h00000000_00010000), 
        .lattice_state(manifold_out), .identity_aligned(identity_lock), .homeopathic_seed(h_seed)
    );

    // 8. Topological Guard
    spu_coherence_ecc guard (
        .clk_fractal(clk_resonant), .rst_n(rst_n), .janus_state(janus_state),
        .coherence_lock(coherence_lock), .phase_correct(phase_correct)
    );

    // 9. IO Bridge (The Standard Interface)
    spu_io_bridge #(
        .CLK_PHYS_HZ(12000000)
    ) u_io (
        .clk_phys(clk_12mhz), .clk_resonant(clk_resonant), .reset(!rst_n),
        .spu_reg_in(manifold_out), .microwatts(microwatts), .sip_active(microwatts < 100),
        .strike_ripple(strike_ripple), .fault_detected(!identity_lock),
        .coherence_lock(coherence_lock), .led_status(), 
        .pmod_ja_out(), .sw_control(4'b0), .serial_rx(1'b1), .serial_tx()
    );

    // 10. Status Reification
    assign led_sat_red = !rst_n | !identity_lock;
    assign led_sat_grn = wake_complete & coherence_lock;
    assign led_sat_blu = (!wake_complete) ? (clk_resonant | sonic_handshake) : q_mood[2];

    assign vector_A = (clk_resonant ^ phase_correct ^ sonic_handshake) & laminar_en;
    assign vector_B = ~vector_A & laminar_en;

endmodule
