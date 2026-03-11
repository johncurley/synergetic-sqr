// SPU-13 Thalamus v3: Central Sensory Relay (v3.4.21)
// Implementation: Metabolic, Proprioceptive, and Frequency Homeostasis.
// Objective: Dynamic frequency adjustment to maintain the 'Purple Glow'.
// Result: Real-time bloom and heartbeat modulation.

module spu_thalamus (
    input  wire        clk_resonant,
    input  wire        reset,

    // Sensory Inputs
    input  wire [11:0] adc_raw,
    input  wire        synergy_idx,
    input  wire        identity_lock,
    input  wire [7:0]  laminar_flow_index, // From Viscosity Monitor

    // Control Outputs
    output wire [15:0] microwatts,
    output reg  [7:0]  bloom_intensity,
    output reg  [3:0]  freq_bias,
    output wire        coherence_lock,
    output wire [3:0]  q_vec
);

    assign microwatts = (adc_raw << 1) + (adc_raw >> 1);

    // Integrated Coherence: Locked + Sipping + Liquid
    assign coherence_lock = identity_lock & (microwatts < 16'd100) & (laminar_flow_index > 8'h80);

    // 1. Homeostatic Modulation
    always @(posedge clk_resonant or posedge reset) begin
        if (reset) begin
            bloom_intensity <= 8'h0;
            freq_bias <= 4'h0;
        end else begin
            // Optimal State: Coherent + Liquid
            if (coherence_lock && synergy_idx) begin
                if (bloom_intensity < 8'hFF) bloom_intensity <= bloom_intensity + 1;
                if (freq_bias > 4'h0) freq_bias <= freq_bias - 1;
            end else begin
                // Turbulent State: Dim and Slow
                if (bloom_intensity > 8'h40) bloom_intensity <= bloom_intensity - 4;
                if (freq_bias < 4'hF) freq_bias <= freq_bias + 1;
            end
        end
    end

    // q_vec[1] is now the 'Liquid' bit
    assign q_vec = {identity_lock, (laminar_flow_index > 8'h80), (bloom_intensity > 8'h80), (microwatts < 16'd50)};

endmodule
