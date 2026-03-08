// SPU-13 TOP-LEVEL REIFICATION CORE (v3.3.52)
// Phase 1.1: Polarity Corrected & Enable-Gated
// Guard: Proactive Coherence ECC & Identity Gate Integrated.

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    input wire laminar_en,   // The 'Throttle' (Pin 10)
    
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

    // 2. The Harmonic Handshake: Sonic Self-Diagnostic
    spu_harmonic_handshake u_sonic (
        .clk_resonant(clk_resonant),
        .rst_n(rst_n),
        .en(laminar_en & !coherence_lock),
        .tone_out(sonic_handshake),
        .handshake_done(boot_done)
    );

    // 3. Identity Gate: The Rational Guard
    // Monitoring the homeopathic seed to ensure topological warmth.
    spu_identity_monad u_identity (
        .clk(clk_resonant),
        .current_quadrance(64'h00000000_00010000), // Identity Quadrance
        .lattice_state({768'b0, h_seed}),
        .identity_aligned(identity_lock),
        .homeopathic_seed(h_seed)
    );

    // 4. The Janus-Gate: Enable-Gated Inversion
    // Included phase_correct and sonic_handshake to kickstart stalled manifold
    assign janus_state = (clk_resonant ^ phase_correct ^ sonic_handshake) & laminar_en;

    // 5. Physical Manifold Drive
    assign vector_A = janus_state;
    assign vector_B = ~janus_state & laminar_en;

    // 6. Topological Guard: Coherence Monitor
    spu_coherence_ecc guard (
        .clk_fractal(clk_resonant),
        .rst_n(rst_n),
        .janus_state(janus_state),
        .coherence_lock(coherence_lock),
        .phase_correct(phase_correct)
    );

    // 7. Status Reification (Visual Handshake)
    // Red = Reset OR Identity Breach
    assign led_sat_red = !rst_n | !identity_lock;
    // Green = Manifold Locked and Aligned
    assign led_sat_grn = coherence_lock & identity_lock & laminar_en;
    // Blue = Handshake sequence active or Searching
    assign led_sat_blu = (!coherence_lock | !boot_done) & laminar_en & (clk_resonant | sonic_handshake);

endmodule
