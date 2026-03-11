// SPU-1 SPERM_X4 Hardware Verification Testbench
// Verifies bit-exact 4D Prime Projection shuffles in RTL simulation.

`timescale 1ns/1ps

module spu_permute_tb;
    reg [255:0] q_in;
    reg [1:0]   prime_phase;
    wire [255:0] q_out;

    // Instantiate SPERM_X4 Unit
    spu_permute uut (
        .q_in(q_in),
        .prime_phase(prime_phase),
        .q_out(q_out)
    );

    initial begin
        $display("--- SPU-1 SPERM_X4 Hardware Verification ---");

        // Initialize with distinct lane values for tracking
        // Q1(a)=1, Q2(b)=2, Q3(c)=3, Q4(d)=4
        q_in = { 64'd4, 64'd3, 64'd2, 64'd1 };

        // Test P1: Identity (Expected: 4, 3, 2, 1)
        prime_phase = 2'd0; #10;
        if (q_out == { 64'd4, 64'd3, 64'd2, 64'd1 }) 
            $display("PASS: P1 (Identity) bit-exact.");
        else 
            $display("FAIL: P1 drift! got %h", q_out);

        // Test P3: 60 deg (b, c, a, d) -> Expected: 4, 1, 3, 2
        prime_phase = 2'd1; #10;
        if (q_out == { 64'd4, 64'd1, 64'd3, 64'd2 }) 
            $display("PASS: P3 (60 deg) bit-exact.");
        else 
            $display("FAIL: P3 drift! got %h", q_out);

        // Test P5: 120 deg (c, a, b, d) -> Expected: 4, 2, 1, 3
        prime_phase = 2'd2; #10;
        if (q_out == { 64'd4, 64'd2, 64'd1, 64'd3 }) 
            $display("PASS: P5 (120 deg) bit-exact.");
        else 
            $display("FAIL: P5 drift! got %h", q_out);

        // Test P7: Hyper-Flip (d, b, c, a) -> Expected: 1, 3, 2, 4
        prime_phase = 2'd3; #10;
        if (q_out == { 64'd1, 64'd3, 64'd2, 64'd4 }) 
            $display("PASS: P7 (Hyper-Flip) bit-exact.");
        else 
            $display("FAIL: P7 drift! got %h", q_out);

        $display("-------------------------------------------");
        $finish;
    end
endmodule
