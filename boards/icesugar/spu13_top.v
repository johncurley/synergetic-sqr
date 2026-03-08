// SPU-13 TOP-LEVEL REIFICATION CORE (v3.3.4)
// Phase 1.1: Polarity Corrected & Enable-Gated
// Target: Lattice iCE40UP5K (iCeSugar)

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    input wire laminar_en,   // The 'Throttle' (High to Enable Flow) (Pin 10)
    
    // Electromagnetic Manifold
    output wire vector_A,    // Inductive Entry (Pin 46)
    output wire vector_B,    // Resonant Return (Pin 47)
    
    // Janus Status Display
    output wire led_sat_red, // System Reset / Stall
    output wire led_sat_grn, // Active Resonant Lock
    output wire led_sat_blu  // Counterspace Pulse
);

    wire clk_fractal;
    wire janus_state;

    // 1. Fractal Heart with Enable Logic
    // Only oscillates when laminar_en is High
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_n),
        .en(laminar_en), 
        .clk_laminar(clk_fractal)
    );

    // 2. The Janus-Gate: Enable-Gated Inversion
    // Mapping the 61.44 kHz pulse to the Null Hysteresis state
    assign janus_state = clk_fractal & laminar_en;

    // 3. Physical Manifold Drive
    assign vector_A = janus_state;
    assign vector_B = ~janus_state & laminar_en; // Mirror remains silent if disabled

    // 4. Status Reification (Visualizing the Flow)
    assign led_sat_grn = janus_state;           // Pulsing Green = Active Lock
    assign led_sat_blu = ~janus_state & laminar_en; // Pulsing Blue = Counterspace
    assign led_sat_red = !rst_n;                // Red = System Reset / Stall

endmodule
