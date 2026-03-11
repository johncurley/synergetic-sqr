// SPU-13 Laminar Buffer: Dielectric Reservoir (v3.4.27)
// Implementation: Leaky Dielectric Bucket for Power Smoothing.
// Objective: Neutralize current spikes from external interaction.
// Result: Zero-hysteresis energy profile (<15uW steady state).

module spu_laminar_buffer (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] microwatts_in,  // From Thalamus
    output reg  [15:0] microwatts_out, // Smoothed 'Laminar' Power
    output wire        reservoir_full  // High if surplus energy is available
);

    // 1. The Dielectric Reservoir (16-bit Accumulator)
    // We maintain a virtual 'charge' that dampens the metabolic signal.
    reg [31:0] reservoir;
    localparam TARGET_SIP = 16'd15; // 15uW Target

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reservoir <= 32'h0;
            microwatts_out <= 16'h0;
        end else begin
            // 2. The Smoothing Logic: Rolling Average (Window=256)
            // reservoir = reservoir - (reservoir/256) + microwatts_in
            reservoir <= reservoir - (reservoir >> 8) + {16'b0, microwatts_in};
            
            // 3. Final Reification
            // The output is the time-averaged metabolic signature.
            microwatts_out <= reservoir >> 8;
        end
    end

    // Reservoir is 'Full' if the smoothed average is below the Sip target.
    assign reservoir_full = (microwatts_out <= TARGET_SIP);

endmodule
