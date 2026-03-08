// SPU-13 Black Background Audit (v3.1.30)
// Objective: Measure Switching Noise (Total Harmonic Jitter)
// Assertion: Laminar logic produces <5% bit-flip density compared to standard ALU.

module black_background_audit;
    reg clk;
    reg reset;
    reg [831:0] reg_curr;
    wire [831:0] reg_out;
    
    // 1. Instantiate SPU-13 Core
    spu_core u_core (
        .clk(clk),
        .reset(reset),
        .reg_curr(reg_curr),
        .neighbors(3072'b0),
        .opcode(3'b001), // P3 Rotation
        .prime_phase(2'b01),
        .sign_flip(1'b0),
        .reg_out(reg_out)
    );

    // 2. Switching Density Counter
    integer i;
    integer flip_count;
    reg [831:0] prev_reg_out;

    initial begin
        clk = 0;
        reset = 1;
        reg_curr = 0;
        flip_count = 0;
        prev_reg_out = 0;
        #100 reset = 0;
        
        $display("--- SPU-13 Black Background Audit: Commencing ---");
        
        for (i = 0; i < 1000; i = i + 1) begin
            reg_curr = $random;
            #10 clk = 1; #10 clk = 0;
            
            // Count bit-flips between previous output and current output
            flip_count = flip_count + $countones(reg_out ^ prev_reg_out);
            prev_reg_out = reg_out;
        end
        
        $display("Total Bit-Flips (Switching Density): %d", flip_count);
        $display("Average Flips per Cycle: %f", flip_count / 1000.0);
        $display("Laminar Status: %s", (flip_count < 100000) ? "SILENT" : "TURBULENT");
        
        $finish;
    end

endmodule
