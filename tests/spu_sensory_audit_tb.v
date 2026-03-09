// SPU-13 Unified Sensory Audit (v3.4.31)
// Objective: Verify the integrated feedback loop (Metabolic + Flow + Thalamus).
// Logic: Inject turbulence and monitor frequency/bloom modulation.

`timescale 1ns/1ps

module spu_sensory_audit_tb();
    reg clk;
    reg reset;
    reg [11:0] adc_raw;
    reg        synergy_idx;
    reg        identity_lock;
    reg [127:0] abcd_vector;
    
    wire [15:0] microwatts;
    wire [7:0]  bloom_intensity;
    wire [3:0]  freq_bias;
    wire        coherence_lock;
    wire [7:0]  flow_idx;

    // 1. Instantiate Sensory Modules
    spu_viscosity_monitor u_visc (
        .clk(clk), .reset(reset),
        .abcd_vector(abcd_vector),
        .laminar_flow_index(flow_idx)
    );

    spu_thalamus u_thal (
        .clk_resonant(clk), .reset(reset),
        .adc_raw(adc_raw), .synergy_idx(synergy_idx), .identity_lock(identity_lock),
        .laminar_flow_index(flow_idx),
        .microwatts(microwatts), .bloom_intensity(bloom_intensity), .freq_bias(freq_bias),
        .coherence_lock(coherence_lock), .q_vec()
    );

    initial begin
        clk = 0; reset = 1; 
        adc_raw = 12'd10; synergy_idx = 1; identity_lock = 1;
        abcd_vector = {32'sd1000, -32'sd1000, 32'sd1000, -32'sd1000}; // Balanced & Flowing
        
        $display("--- Sensory Audit: Initializing Consciousness ---");
        #100 reset = 0;
        
        // Step 1: Deep Resonance (The Sip)
        #1000;
        $display("Status: Deep Resonance. Power: %d uW | Bloom: %d | FreqBias: %d", 
                 microwatts, bloom_intensity, freq_bias);
        
        // Step 2: Inject Cubic Friction (Asymmetry)
        $display("Injecting Cubic Friction...");
        abcd_vector = {32'sd1000, 32'sd0, 32'sd0, 32'sd0}; // Unbalanced
        #500;
        $display("Status: Turbulent. FlowIdx: %d | Bloom: %d | FreqBias: %d", 
                 flow_idx, bloom_intensity, freq_bias);
        
        // Step 3: Inject Metabolic Pressure (The Gulp)
        $display("Injecting Metabolic Pressure (500uW)...");
        adc_raw = 12'd200; 
        #500;
        $display("Status: Gulping. Power: %d uW | Coherence: %b | FreqBias: %d", 
                 microwatts, coherence_lock, freq_bias);

        if (freq_bias > 0 && bloom_intensity < 255)
            $display("PASS: Thalamic Homeostasis Verified.");
        else
            $display("FAIL: System failed to self-regulate.");
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
