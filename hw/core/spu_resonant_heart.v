// SPU-13 Resonant Heart (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Derive the 61.44 kHz 'Master Tone' from hardware clock.
// Rationale: Harmonic sub-multiple of the 61440 Hz universal frequency.

module spu_resonant_heart #(
    parameter CLK_IN_HZ = 12000000
)(
    input  wire clk_in,
    input  wire rst_n,
    output reg  clk_resonant // 61.44 kHz Pulse
);

    // Divider = 12,000,000 / 61,440 = 195.3125
    // We use a fixed divider of 195 for 61.538 kHz (Laminar Approximation)
    localparam DIVIDER = 195;
    reg [7:0] counter;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_resonant <= 0;
        end else begin
            if (counter >= (DIVIDER/2 - 1)) begin
                counter <= 0;
                clk_resonant <= ~clk_resonant;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
