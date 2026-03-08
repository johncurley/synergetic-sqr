// SPU-13 Rational Trigonometry Testbench (v3.3.22)
// Objective: Verify bit-exact Quadrance and 60° Spread Invariant.
// Status: Symmetry Guard (Cubic Decomposition) Verified.

`timescale 1ns/1ps

module spu_rational_trig_tb();
    reg signed [31:0] a, b, c, d;
    wire [63:0] quadrance;
    wire [31:0] spread_60;
    wire [95:0] a_cubic;

    // 1. Instantiate the Rational Core
    spu_rational_trig u_trig (
        .a(a), .b(b), .c(c), .d(d),
        .quadrance(quadrance),
        .spread_60_fixed(spread_60),
        .a_cubic_laminar(a_cubic),
        .b_cubic_laminar(),
        .c_cubic_laminar(),
        .d_cubic_laminar()
    );

    initial begin
        $display("--- SPU-13 Rational Trig Audit: Commencing ---");

        // Test 1: Identity Quadrance
        a = 32'sd1; b = 32'sd0; c = 32'sd0; d = 32'sd0;
        #10;
        if (quadrance === 64'd1) 
            $display("PASS: Identity Quadrance (Q=1) Verified.");
        else 
            $display("FAIL: Identity Quadrance expected 1, got %d", quadrance);

        // Test 2: Tetrahedral Symmetry (Unit vectors)
        a = 32'sd1; b = 32'sd1; c = 32'sd1; d = 32'sd1;
        #10;
        if (quadrance === 64'd4)
            $display("PASS: Tetrahedral Sum Quadrance (Q=4) Verified.");
        else
            $display("FAIL: Tetrahedral Sum Quadrance expected 4, got %d", quadrance);

        // Test 3: Large Coordinate Stress
        a = 32'sd10000; b = -32'sd5000; c = 32'sd2500; d = 32'sd0;
        #10;
        if (quadrance === 64'd131250000)
            $display("PASS: Large Coordinate Quadrance Verified.");
        else
            $display("FAIL: Large Quadrance mismatch.");

        // Test 4: Spread Invariant
        if (spread_60 === 32'h0000C000)
            $display("PASS: 60-degree Spread Invariant (0.75) Verified.");
        else
            $display("FAIL: Spread Invariant mismatch.");

        // Test 5: Symmetry Guard (Cubic Decomposition)
        a = 32'sd3; // Q = 9, Cubic = 27
        #10;
        if (a_cubic === 96'd27)
            $display("PASS: Symmetry Guard (Cubic Decomposition) Verified (3^3 = 27).");
        else
            $display("FAIL: Symmetry Guard decomposition expected 27, got %d", a_cubic);

        $display("--- Rational Trig Audit: COMPLETE (Bit-Exact) ---");
        $finish;
    end

endmodule
