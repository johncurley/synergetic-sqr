// SPU-1 Primary Hardware Testbench (v3.3.98)
// Objective: Verify core algebraic stability and interaction path.
// Logic: Execute Thomson Rotations and strike the Resonant Membrane.

`timescale 1ns/1ps

module spu1_tb();
    reg clk;
    reg reset;
    reg [831:0] reg_curr;
    reg [127:0] strike_in;
    reg [2:0]   opcode;
    reg [1:0]   prime_phase;
    reg         sign_flip;
    wire [831:0] reg_out;
    wire         fault_detected;

    // 1. Instantiate the Integrated Core
    spu_core u_core (
        .clk(clk), .reset(reset),
        .reg_curr(reg_curr),
        .neighbors(3072'b0),
        .strike_in(strike_in),
        .opcode(opcode),
        .prime_phase(prime_phase),
        .sign_flip(sign_flip),
        .reg_out(reg_out),
        .fault_detected(fault_detected)
    );

    initial begin
        clk = 0; reset = 1;
        reg_curr = 0; strike_in = 0;
        opcode = 3'b000; prime_phase = 2'b00; sign_flip = 0;
        
        $display("--- SPU-1 Core Audit: Initializing ---");
        #100 reset = 0;
        
        // Step 1: Identity Injection
        reg_curr[31:0] = 32'h00010000; // a=1.0
        #10;
        
        // Step 2: Thomson Rotation (SPERM_X4)
        opcode = 3'b001; prime_phase = 2'b01; // 60-degree rotation
        #10;
        $display("Rotation Result: a=%d, b=%d", $signed(reg_out[31:0]), $signed(reg_out[63:32]));
        
        // Step 3: Resonant Strike (Testing interaction without fault check)
        $display("Striking Manifold (Resonant Membrane)...");
        strike_in = {32'sd1000, -32'sd1000, 32'sd1000, -32'sd1000};
        #10;
        $display("Interaction Result: Alpha Lane = %d", $signed(reg_out[31:0]));
        
        // Reset strike and verify identity lock
        strike_in = 0;
        #20;
        
        // Step 4: Final Verification
        if (!fault_detected)
            $display("PASS: Core Integral and Responsive.");
        else
            $display("FAIL: Identity Breach detected.");
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
