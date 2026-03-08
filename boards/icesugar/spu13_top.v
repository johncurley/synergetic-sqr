// SPU-13 TOP-LEVEL REIFICATION CORE (v3.3.8)
// Phase 1.1: Polarity Corrected & Enable-Gated
// Guard: Proactive Coherence ECC Integrated

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    input wire laminar_en,   // The 'Throttle' (High to Enable Flow) (Pin 10)
    
    // Electromagnetic Manifold
    output wire vector_A,    // Inductive Entry (Pin 46)
    output wire vector_B,    // Resonant Return (Pin 47)
    
    // Janus Status Display
    output wire led_sat_red, // Absence of the One (Reset)
    output wire led_sat_grn, // The One is Present (Laminar Lock)
    output wire led_sat_blu  // Searching for the One (Primer/Unlock)
);

    wire clk_resonant;
    wire janus_state;
    wire coherence_lock;
    wire phase_correct;
    wire sonic_handshake;
    wire boot_done;

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
        .en(laminar_en & !coherence_lock), // Active during Primer phase
        .tone_out(sonic_handshake),
        .handshake_done(boot_done)
    );

    // 3. The Janus-Gate: Enable-Gated Inversion
    // Included phase_correct and sonic_handshake to kickstart stalled manifold
    assign janus_state = (clk_resonant ^ phase_correct ^ sonic_handshake) & laminar_en;

    // 4. Physical Manifold Drive
    assign vector_A = janus_state;
    assign vector_B = ~janus_state & laminar_en;

    // 5. Topological Guard: Coherence Monitor
    spu_coherence_ecc guard (
        .clk_fractal(clk_resonant),
        .rst_n(rst_n),
        .janus_state(janus_state),
        .coherence_lock(coherence_lock),
        .phase_correct(phase_correct)
    );

    // 6. Status Reification (The Visual Handshake)
    assign led_sat_red = !rst_n;                                // Red = Stall/Reset
    assign led_sat_grn = coherence_lock & laminar_en;           // Green = The One is Present
    assign led_sat_blu = !coherence_lock & laminar_en & (clk_resonant | sonic_handshake); // Blue Breathing + Sonic Presence

endmodule
