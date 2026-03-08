// SPU-13 TOP-LEVEL REIFICATION CORE (v3.1.34)
// Phase 1: The Resonant Anchor
// Target: Lattice iCE40UP5K (iCeSugar)

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_btn,      // Manual Reset (Pin 18)
    
    // Electromagnetic Manifold
    output wire vector_A,    // Inductive Entry (Pin 46)
    output wire vector_B,    // Resonant Return (Pin 47)
    
    // Janus Status Display
    output wire led_sat_red, // Turbulence
    output wire led_sat_grn, // Resonant Lock
    output wire led_sat_blu  // Counterspace
);

    wire clk_fractal;
    wire janus_state;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_btn),
        .clk_laminar(clk_fractal)
    );

    // 2. The Janus-Gate: Phase-Locked Inversion
    // Mapping the 61.44 kHz pulse to the Null Hysteresis state
    assign janus_state = clk_fractal;

    // 3. Physical Manifold Drive
    // Driving the "Virtual Coils" with the fractal pulse
    assign vector_A = janus_state;
    assign vector_B = ~janus_state; // Chiral Mirror

    // 4. Status Reification (Visualizing the Flow)
    assign led_sat_grn = janus_state;   // Flashing at Resonant Lock
    assign led_sat_blu = ~janus_state;  // Flashing at Counterspace Entry
    assign led_sat_red = 1'b0;          // Keep Turbulence OFF

endmodule
