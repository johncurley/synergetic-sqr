// SPU-13 Bowman Wake Audit (v3.3.79)
// Objective: Verify the 5-phase automated boot sequence.
// Logic: Monitor boot_phase transitions and wake_complete signal.

`timescale 1ns/1ps

module spu_bowman_wake_tb();
    reg clk;
    reg rst_n;
    reg en;
    reg handshake_done;
    reg identity_lock;
    wire [2:0] boot_phase;
    wire wake_complete;

    // 1. Instantiate the Sequencer
    spu_bowman_sequencer u_wake (
        .clk(clk), .rst_n(rst_n), .en(en),
        .handshake_done(handshake_done),
        .identity_lock(identity_lock),
        .boot_phase(boot_phase),
        .wake_complete(wake_complete)
    );

    initial begin
        clk = 0; rst_n = 0; en = 0;
        handshake_done = 0; identity_lock = 0;
        
        $display("--- Bowman Wake Audit: Initializing Void ---");
        #100 rst_n = 1;
        #100 en = 1; // Pull the throttle
        
        $display("Phase 0 (Withdrawal): boot_phase = %b", boot_phase);
        #20;
        
        $display("Phase 1 (Handshake): boot_phase = %b", boot_phase);
        #100 handshake_done = 1; // Sonic diagnostic complete
        
        #20;
        $display("Phase 2 (Saturation): boot_phase = %b", boot_phase);
        
        // Wait for saturation timer (1024 cycles)
        #15000;
        
        $display("Phase 3 (Alignment): boot_phase = %b", boot_phase);
        #100 identity_lock = 1; // IVM Lattice Lock achieved
        
        #20;
        $display("Phase 4 (Resonance): boot_phase = %b | wake_complete = %b", boot_phase, wake_complete);
        
        if (wake_complete && boot_phase == 3'b100)
            $display("PASS: Bowman Wake-Up Sequence Absolute.");
        else
            $display("FAIL: Sequencer stalled in phase %b", boot_phase);
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
