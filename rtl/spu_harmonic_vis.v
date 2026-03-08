// SPU-13 Harmonic Visualization Engine (v3.3.29)
// Implementation: Projective Geometry for Auditory Fractals.
// Objective: Visualize Octave Nesting and Rational Intervals.
// Status: [RESONANCE ACTIVE] - Initializing with Soft-Start.

module spu_harmonic_vis (
    input  wire         clk,
    input  wire         reset,
    input  wire [15:0]  freq_in,      // Musical Frequency Component
    input  wire [7:0]   amplitude,    // Manifold Depth
    output wire [31:0]  color_out,    // Harmonic Color Mapping
    output wire [63:0]  vector_out    // Projective Quadray Vector (A,B)
);

    // 1. Octave Nesting (Recursive Shell)
    // Map frequency to a radial depth. Each octave is a concentric circle.
    // Higher frequencies spiral inward toward the center (The One).
    wire [3:0] octave = freq_in[15:12];
    wire [11:0] phase = freq_in[11:0]; // Phase within the octave

    // 2. Rational Intervals as Vectors
    // We treat the frequency phase as a Spread (s) in the IVM lattice.
    // Rational intervals (3/2, 4/3) map to exact 60/120 degree vectors.
    wire signed [31:0] vec_a, vec_b;
    
    // Simplistic projective mapping for Phase 1 (Square of the Phase)
    assign vec_a = ($signed({1'b0, phase}) * $signed({1'b0, amplitude})) >> 8;
    assign vec_b = ($signed({1'b0, octave}) * 32'sd4096); // Octave depth

    assign vector_out = {vec_b, vec_a};

    // 3. Harmonic Color Scaling
    // Mapping the color spectrum to the musical octaves.
    // Red = Base Octave, Violet = High Octave.
    assign color_out = {
        octave[3:0], 4'h0,      // R (Octave bias)
        phase[11:8],            // G (Harmonic detail)
        amplitude[7:4],         // B (Manifold intensity)
        8'hFF                   // Alpha
    };

endmodule
