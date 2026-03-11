// SPU-1 SMUL Testbench
// Verifies bit-exact identity restoration in hardware simulation

`timescale 1ns/1ps

module spu_smul_tb;
    reg  signed [31:0] a1, b1, a2, b2;
    wire signed [31:0] res_a, res_b;

    // Instantiate the Unit Under Test (UUT)
    spu_smul uut (
        .a1(a1), .b1(b1), .a2(a2), .b2(b2),
        .res_a(res_a), .res_b(res_b)
    );

    initial begin
        $display("--- SPU-1 SMUL Hardware Verification ---");

        // Test 1: Identity Multiplication (1.0 * 1.0)
        a1 = 65536; b1 = 0; a2 = 65536; b2 = 0;
        #10;
        if (res_a == 65536 && res_b == 0) 
            $display("PASS: Identity Multiplication bit-exact.");
        else 
            $display("FAIL: Identity drift! a=%d b=%d", res_a, res_b);

        // Test 2: Surd Squared (sqrt3 * sqrt3 = 3.0)
        a1 = 0; b1 = 65536; a2 = 0; b2 = 65536;
        #10;
        if (res_a == 196608 && res_b == 0) 
            $display("PASS: Surd Squared (3.0) bit-exact.");
        else 
            $display("FAIL: Surd drift! a=%d b=%d", res_a, res_b);

        // Test 3: Complex Interaction (Identity + Surd)
        a1 = 65536; b1 = 65536; a2 = 65536; b2 = 0;
        #10;
        if (res_a == 65536 && res_b == 65536) 
            $display("PASS: Complex Interaction bit-exact.");
        else 
            $display("FAIL: Complex drift! a=%d b=%d", res_a, res_b);

        $display("---------------------------------------");
        $finish;
    end
endmodule
