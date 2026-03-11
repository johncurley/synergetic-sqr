// SPU-13 Resonance Audit (v1.0)
// Target: iCE40UP5K (Spare LUT optimization)
// Objective: Monitor the 61.44 kHz Artery for temporal dissonance.
// Logic: Real-time period audit with immediate damping trigger.

module spu_resonance_audit (
    input  wire        clk,
    input  wire        reset,
    input  wire        heartbeat_in, // 61.44 kHz Pulse
    output reg         dissonance_detected,
    output reg  [7:0]  drift_magnitude
);

    // Baseline: 12MHz / 61.44kHz = 195 cycles
    localparam TARGET_PERIOD = 8'd195;
    localparam TOLERANCE     = 8'd4;

    reg [7:0] period_cnt;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            period_cnt <= 0;
            dissonance_detected <= 0;
            drift_magnitude <= 0;
        end else begin
            if (heartbeat_in) begin
                // Check if the previous period was 'Sane'
                if (period_cnt > (TARGET_PERIOD + TOLERANCE) || 
                    period_cnt < (TARGET_PERIOD - TOLERANCE)) begin
                    dissonance_detected <= 1;
                    drift_magnitude <= (period_cnt > TARGET_PERIOD) ? 
                                       (period_cnt - TARGET_PERIOD) : 
                                       (TARGET_PERIOD - period_cnt);
                end else begin
                    dissonance_detected <= 0;
                    drift_magnitude <= 0;
                end
                period_cnt <= 0;
            end else begin
                if (period_cnt < 8'hFF) period_cnt <= period_cnt + 1;
            end
        end
    end

endmodule
