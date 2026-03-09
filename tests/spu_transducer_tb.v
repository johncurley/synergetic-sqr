// SPU-13 Transduction Audit (v3.3.83)
// Objective: Verify ASCII-to-Quadray conversion and natural decay.
// Logic: Strike membrane with 'A', 'B', 'C' and monitor 4D ripples.

`timescale 1ns/1ps

module spu_transducer_tb();
    reg clk;
    reg reset;
    reg [7:0] ascii_in;
    reg data_valid;
    wire [127:0] ripple_out;
    wire membrane_lock;

    // 1. Instantiate the Transducer
    spu_harmonic_transducer u_trans (
        .clk(clk), .reset(reset),
        .ascii_in(ascii_in), .data_valid(data_valid),
        .ripple_out(ripple_out), .membrane_lock(membrane_lock)
    );

    integer i;
    initial begin
        clk = 0; reset = 1;
        ascii_in = 8'h0; data_valid = 0;
        
        $display("--- Transduction Audit: Initializing Membrane ---");
        #100 reset = 0;
        
        // Step 1: Strike 'A' (8'h41)
        $display("Striking Membrane: 'A' (8'h41)...");
        ascii_in = 8'h41; data_valid = 1;
        #10 data_valid = 0;
        
        // Observe propagation
        for (i = 0; i < 32; i = i + 1) begin
            #10 if (i % 8 == 0) 
                $display("Cycle %d: Ripple A=%d, B=%d, C=%d, D=%d", i, 
                    $signed(ripple_out[31:0]), $signed(ripple_out[63:32]), 
                    $signed(ripple_out[95:64]), $signed(ripple_out[127:96]));
        end
        
        // Step 2: Strike 'B' (8'h42)
        $display("Striking Membrane: 'B' (8'h42)...");
        ascii_in = 8'h42; data_valid = 1;
        #10 data_valid = 0;
        #100;

        // Step 3: Observe Decay to Lock
        $display("Observing Natural Decay to Equilibrium...");
        for (i = 0; i < 200; i = i + 1) begin
            #10;
            if (i % 50 == 0)
                $display("Cycle %d: A Component = %d", i + 32, $signed(ripple_out[31:0]));
        end
        
        if ($signed(ripple_out[31:0]) < 1000)
            $display("PASS: Membrane decaying toward Resonant Lock.");
        else
            $display("FAIL: Decay constant too low or manifold turbulent.");
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
