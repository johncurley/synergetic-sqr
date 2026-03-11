// SPU-13 PWM Audio Driver (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Convert 4D Quadray Ripples into Auditory Waves.
// Logic: 16-bit High-Frequency Carrier (Approx 187 kHz @ 12MHz).

module spu_pwm_audio (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] sample_in, // From Transducer / Davis Gate
    output reg         audio_out
);

    // 1. High-Resolution PWM Counter
    reg [15:0] counter;
    always @(posedge clk or posedge reset) begin
        if (reset) counter <= 16'b0;
        else counter <= counter + 1;
    end

    // 2. Sample Latch (Laminar Synchronization)
    // We update the duty cycle only when the counter wraps
    reg [15:0] duty_cycle;
    always @(posedge clk or posedge reset) begin
        if (reset) duty_cycle <= 16'h8000; // Neutral Silence
        else if (counter == 16'hFFFF) begin
            // Map 32-bit internal sample to 16-bit PWM range
            // Centered at 0x8000
            duty_cycle <= sample_in[31:16] + 16'h8000;
        end
    end

    // 3. The Comparison (Phase-Locked Emission)
    always @(*) begin
        audio_out = (counter < duty_cycle);
    end

endmodule
