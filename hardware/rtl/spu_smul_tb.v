// SPU-1 SMUL Testbench
// Verifies bit-exact identity restoration in hardware simulation

`timescale 1ns/1ps

module spu_smul_tb;
    reg  signed [31:0] a1, b1, a2, b2;
    wire signed [31:0] a_out, b_out;

    // Instantiate the Unit Under Test (UUT)
    spu_smul uut (
        .a1(a1), .b1(b1), .a2(a2), .b2(b2),
        .a_out(a_out), .b_out(b_out)
    );

    initial begin
        $display("--- SPU-1 SMUL Hardware Verification ---");

        // Test 1: Identity Multiplication (1.0 * 1.0)
        a1 = 65536; b1 = 0; a2 = 65536; b2 = 0;
        #10;
        if (a_out == 65536 && b_out == 0) 
            $display("PASS: Identity Multiplication bit-exact.");
        else 
            $display("FAIL: Identity drift! a=%d b=%d", a_out, b_out);

        // Test 2: Surd Squared (sqrt3 * sqrt3 = 3.0)
        a1 = 0; b1 = 65536; a2 = 0; b2 = 65536;
        #10;
        if (a_out == 196608 && b_out == 0) 
            $display("PASS: Surd Squared (3.0) bit-exact.");
        else 
            $display("FAIL: Surd drift! a=%d b=%d", a_out, b_out);

        // Test 3: Complex Interaction (Identity + Surd)
        a1 = 65536; b1 = 65536; a2 = 65536; b2 = 0;
        #10;
        if (a_out == 65536 && b_out == 65536) 
            $display("PASS: Complex Interaction bit-exact.");
        else 
            $display("FAIL: Complex drift! a=%d b=%d", a_out, b_out);

        $display("---------------------------------------");
        $finish;
    end
endmodule
