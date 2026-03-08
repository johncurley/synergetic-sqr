// SPU-13 TOP-LEVEL REIFICATION CORE (v3.1.36)
// Target: Lattice iCE40UP5K (iCeSugar)
// Implementation: Universal Fractal Heart (61.44 kHz)

module spu13_top (
    input wire clk_12mhz,    // Physical Oscillator (Pin 35)
    input wire rst_n,        // Active-Low Reset (Pin 18)
    
    // Electromagnetic Manifold
    output wire vector_A,    // Inductive Entry (Pin 46)
    output wire vector_B,    // Resonant Return (Pin 47)
    
    // Janus Status Display
    output wire led_sat_red, // Turbulence
    output wire led_sat_grn, // Resonant Lock
    output wire led_sat_blu  // Counterspace
);

    wire clk_resonant;
    wire janus_state;

    // 1. The Fractal Heart: Sierpiński Oscillator
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) fractal_osc (
        .clk_in(clk_12mhz),
        .rst_n(rst_n),
        .clk_laminar(clk_resonant)
    );

    // 2. The Janus-Gate: Phase-Locked Inversion
    assign janus_state = clk_resonant;

    // 3. Physical Manifold Drive
    assign vector_A = janus_state;
    assign vector_B = ~janus_state; // Chiral Mirror

    // 4. Status Reification
    assign led_sat_grn = janus_state;
    assign led_sat_blu = ~janus_state;
    assign led_sat_red = 1'b0;

endmodule
