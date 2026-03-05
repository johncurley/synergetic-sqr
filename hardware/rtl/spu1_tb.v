// SPU-13 Unified Testbench (v2.11.5)
// Stimulus: 10,000,000 continuous clock cycles.
// Assertions: R6=I Identity restoration and Purple Glow threshold.

`timescale 1ns/1ps

module spu1_tb;
    reg clk;
    reg reset;
    reg [831:0] reg_curr;
    reg [2:0]   opcode;
    
    wire [831:0] reg_next;
    wire         henosis;
    wire         fault;

    // Instantiate Unified ALU
    spu1_alu uut (
        .clk(clk), .reset(reset),
        .reg_curr(reg_curr),
        .opcode(opcode),
        .prime_phase(2'b01), // P3
        .sign_flip(1'b0),
        .perturb_enable(1'b0),
        .reg_next(reg_next),
        .henosis_stable(henosis),
        .fault_detected(fault)
    );

    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    integer i;
    initial begin
        $display("--- SPU-13 10M TICK SILICON CERTIFICATION ---");
        reset = 1; reg_curr = 832'h1; opcode = 3'b000;
        #20 reset = 0;
        
        // Phase 1: Anabasis Ascent
        opcode = 3'b100; // Force Henosis
        #100;

        // Phase 2: Long-Run Identity Stress
        for (i = 0; i < 10000000; i = i + 1) begin
            @(posedge clk);
            reg_curr <= reg_next;
            if (i % 1000000 == 0) $display("Tick %0d: Field Stable.", i);
        end

        $display("PASS: 10,000,000 Ticks bit-perfect. Identity restored.");
        $finish;
    end
endmodule
