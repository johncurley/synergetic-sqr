// SPU-13 Seed Heart (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: The Absolute Minimal Resonant Core (<50 LUTs).
// Logic: 61.44 kHz Heartbeat + 1-bit Artery Listen.
// Vibe: The Single Cell.

module spu_seed_heart #(
    parameter CLK_HZ = 12000000
)(
    input  wire clk,
    input  wire rst_n,
    output wire heartbeat,
    input  wire artery_in,
    output reg  awake
);

    // 1. Minimal 61.44 kHz pulse (195 cycles @ 12MHz)
    reg [7:0] cnt;
    assign heartbeat = (cnt == 8'd195);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            awake <= 0;
        end else begin
            if (heartbeat) cnt <= 0;
            else cnt <= cnt + 1;
            
            // 2. Simple "Wake" detection on Artery
            if (artery_in) awake <= 1;
        end
    end

endmodule
