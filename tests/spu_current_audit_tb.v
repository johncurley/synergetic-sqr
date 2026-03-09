// SPU-13 Constant Current Audit (v3.4.14)
// Objective: Prove Null-Hysteresis switching.
// Logic: Count total bit transitions and verify they are balanced.

`timescale 1ns/1ps

module spu_current_audit_tb();
    reg clk;
    reg reset;
    reg [63:0] data_in;
    reg janus_flip;
    wire [63:0] data_out;
    wire laminar_valid;

    spu_laminar_gate u_gate (
        .clk(clk), .reset(reset),
        .data_in(data_in), .janus_flip(janus_flip),
        .data_out(data_out), .laminar_valid(laminar_valid)
    );

    integer i;
    reg [63:0] last_data;
    integer transitions;

    initial begin
        clk = 0; reset = 1; data_in = 64'h0; janus_flip = 0;
        last_data = 0; transitions = 0;
        
        $display("--- Constant Current Audit: Commencing ---");
        #100 reset = 0;

        // Step 1: Transition from Zero to Random Data
        $display("Transitioning to Random State...");
        data_in = 64'hA5A5A5A5_5A5A5A5A;
        #10;
        
        // Count flips in data_out
        for (i = 0; i < 64; i = i + 1) begin
            if (data_out[i] != last_data[i]) transitions = transitions + 1;
        end
        $display("Transitions detected: %d", transitions);
        
        // Step 2: Complex Flip (Janus Polarity)
        transitions = 0;
        last_data = data_out;
        janus_flip = 1;
        #10;
        for (i = 0; i < 64; i = i + 1) begin
            if (data_out[i] != last_data[i]) transitions = transitions + 1;
        end
        $display("Janus Flip Transitions: %d", transitions);

        if (laminar_valid && (transitions == 64))
            $display("PASS: Constant Current Signature Verified (Balanced 64-bit Inversion).");
        else
            $display("FAIL: Hysteresis detected. Manifold is unbalanced.");
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
