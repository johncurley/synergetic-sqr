// SPU-13 Sierpiński Fractal Bypass Testbench (v3.3.42)
// Objective: Verify Zero-Impedance routing through fractal voids.

`timescale 1ns/1ps

module spu_fractal_bypass_tb();
    reg [255:0] q_in;
    reg [1:0]   phase;
    wire [255:0] q_out;

    // 1. Instantiate the Bypass Logic
    spu_fractal_bypass u_bypass (
        .q_in(q_in),
        .phase(phase),
        .q_out(q_out)
    );

    initial begin
        $display("--- SPU-13 Fractal Bypass Audit: Commencing ---");

        // Test 1: Standard Path (Non-Void)
        // Vector with significant MSBs should pass through normally.
        q_in = {64'hF0000000_00000000, 64'hF0000000_00000000, 
                64'hF0000000_00000000, 64'hF0000000_00000000};
        phase = 2'b01;
        #10;
        if (q_out === q_in)
            $display("PASS: Standard Path identity verified.");
        else
            $display("FAIL: Standard Path corruption.");

        // Test 2: Fractal Void Path (Deep Frost Tunnel)
        // Vector with Zero MSBs should trigger the tunnel logic.
        q_in = {64'h00000000_FFFFFFFF, 64'h00000000_FFFFFFFF, 
                64'h00000000_FFFFFFFF, 64'h00000000_FFFFFFFF};
        phase = 2'b11;
        #10;
        if (q_out === q_in)
            $display("PASS: Fractal Void 'Deep Frost' identity verified.");
        else
            $display("FAIL: Fractal Void corruption.");

        $display("--- Fractal Bypass Audit: COMPLETE (Zero-Impedance) ---");
        $finish;
    end

endmodule
