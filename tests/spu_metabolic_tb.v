// SPU-13 Metabolic Audit (v3.3.99)
// Objective: Verify uW calculation and Sip-active threshold.

`timescale 1ns/1ps

module spu_metabolic_tb();
    reg clk;
    reg reset;
    reg [11:0] adc_raw;
    wire [15:0] microwatts;
    wire sip_active;

    spu_metabolic_sense u_sense (
        .clk(clk), .reset(reset),
        .adc_raw(adc_raw), .microwatts(microwatts),
        .sip_active(sip_active)
    );

    initial begin
        clk = 0; reset = 1; adc_raw = 0;
        #100 reset = 0;

        // Step 1: Sub-threshold (The Sip)
        $display("Testing Sub-threshold Metabolic Rate...");
        adc_raw = 12'd20; // Simulated low current
        #20;
        $display("ADC: %d | Power: %d uW | Sip: %b", adc_raw, microwatts, sip_active);
        
        // Step 2: High power (Cubic Friction)
        $display("Testing Turbulent Power Draw...");
        adc_raw = 12'd500;
        #20;
        $display("ADC: %d | Power: %d uW | Sip: %b", adc_raw, microwatts, sip_active);

        if (sip_active == 0 && microwatts > 1000)
            $display("PASS: Metabolic Awareness Verified.");
        else
            $display("FAIL: Scaling or Threshold error.");

        $finish;
    end

    always #5 clk = ~clk;

endmodule
