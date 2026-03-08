// SPU-13 Harmonic Visualization Testbench (v3.3.30)
// Objective: Verify projective geometry of auditory fractals.

`timescale 1ns/1ps

module spu_harmonic_vis_tb();
    reg clk;
    reg reset;
    reg [15:0] freq_in;
    reg [7:0]  amplitude;
    wire [31:0] color_out;
    wire [63:0] vector_out;

    // 1. Instantiate the Engine
    spu_harmonic_vis u_vis (
        .clk(clk), .reset(reset),
        .freq_in(freq_in),
        .amplitude(amplitude),
        .color_out(color_out),
        .vector_out(vector_out)
    );

    initial begin
        clk = 0;
        reset = 1;
        freq_in = 0;
        amplitude = 0;
        #20 reset = 0;

        $display("--- SPU-13 Harmonic Vis Audit: Commencing ---");

        // Test 1: Base Octave (Recursive Shell 0)
        freq_in = 16'h0ABC; // Low frequency
        amplitude = 8'hFF;
        #10;
        $display("Octave 0 Mapping: Color=%h, Vector=%h", color_out, vector_out);

        // Test 2: High Octave (Inward Spiral)
        freq_in = 16'hFABC; // Max frequency
        amplitude = 8'hFF;
        #10;
        $display("Octave 15 Mapping: Color=%h, Vector=%h", color_out, vector_out);

        // Test 3: Rational Interval (Perfect Fifth Phase Check)
        // 3/2 relationship would manifest in the 'phase' bits (freq_in[11:0])
        freq_in = 16'h1800; // Octave 1, Phase 0x800
        #10;
        if (vector_out[63:32] === 32'd4096)
            $display("PASS: Octave Depth projection verified.");
        else
            $display("FAIL: Octave Depth projection mismatch.");

        $display("--- Harmonic Vis Audit: COMPLETE ---");
        $finish;
    end

    always #5 clk = ~clk;

endmodule
