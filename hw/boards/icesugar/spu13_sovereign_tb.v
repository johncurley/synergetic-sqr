`timescale 1ns/1ps

module spu13_sovereign_tb;
    reg clk;
    reg reset;
    reg [11:0] lean;
    wire [47:0] depth;

    // Instantiate the Sovereign Top Module (The "Brain")
    spu13_sovereign_top uut (
        .clk(clk),
        .reset(reset),
        .lean(lean),
        .depth(depth)
    );

    // Generate a 12MHz "Pulse" (approx 83.3ns period, half-period ~41.6ns)
    always #41.6 clk = ~clk; 

    initial begin
        // Setup Waveform Dump for GTKWave
        $dumpfile("spu13_sovereign.vcd");
        $dumpvars(0, spu13_sovereign_tb);

        clk = 0; reset = 1; lean = 0;
        #100 reset = 0; // Release the Invariant
        
        // Simulate a "Liquid" Lean on the skateboard
        #100 lean = 12'h100; 
        #500 lean = 12'h500;
        
        #5000 $finish; // End the "Sip"
    end
endmodule
