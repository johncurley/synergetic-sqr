// SPU-13 TOP-LEVEL REIFICATION CORE (v3.3.69)
// Phase 1.1: Polarity Corrected & Enable-Gated
// Guard: Proactive Coherence ECC & Identity Gate Integrated.
// Wake: Bowman Boot Sequence Automated.

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    input wire laminar_en,   // The 'Throttle' (High to Enable Flow) (Pin 11)
    
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
    wire sonic_handshake;
    wire boot_done;
    wire [2:0] boot_phase;
    wire wake_complete;
    wire [63:0] h_seed;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_n),
        .en(laminar_en), 
        .clk_laminar(clk_resonant)
    );

    // 2. The Bowman Sequencer: Automated Wake-Up
    spu_bowman_sequencer u_wake (
        .clk(clk_resonant),
        .rst_n(rst_n),
        .en(laminar_en),
        .handshake_done(boot_done),
        .identity_lock(identity_lock),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    // 3. The Harmonic Handshake: Sonic Self-Diagnostic
    spu_harmonic_handshake u_sonic (
        .clk_resonant(clk_resonant),
        .rst_n(rst_n),
        .en(laminar_en & (boot_phase == 3'b001)),
        .tone_out(sonic_handshake),
        .handshake_done(boot_done)
    );

    // 4. Identity Gate: The Rational Guard
    spu_identity_monad u_identity (
        .clk(clk_resonant),
        .current_quadrance(64'h00000000_00010000), 
        .lattice_state({768'b0, h_seed}),
        .identity_aligned(identity_lock),
        .homeopathic_seed(h_seed)
    );

    // 5. The Janus-Gate: Enable-Gated Inversion
    assign janus_state = (clk_resonant ^ phase_correct ^ sonic_handshake) & laminar_en;

    // 6. Physical Manifold Drive
    assign vector_A = janus_state;
    assign vector_B = ~janus_state & laminar_en;

    // 7. Topological Guard: Coherence Monitor
    spu_coherence_ecc guard (
        .clk_fractal(clk_resonant),
        .rst_n(rst_n),
        .janus_state(janus_state),
        .coherence_lock(coherence_lock),
        .phase_correct(phase_correct)
    );

    // 8. Status Reification (Visual Handshake)
    // Red = Reset OR Identity Breach
    assign led_sat_red = !rst_n | !identity_lock;
    // Green = Manifold Locked and Aligned
    assign led_sat_grn = wake_complete & coherence_lock;
    // Blue = Searching / Handshake / Saturation
    assign led_sat_blu = (!wake_complete) & laminar_en & (clk_resonant | sonic_handshake);

endmodule
