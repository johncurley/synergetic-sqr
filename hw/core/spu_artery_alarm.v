// SPU-13 Artery Alarm (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Detect phase-drift in biological 61.44 kHz pulse.
// Result: Signal 'Refractive Reset' if resonance is lost.

module spu_artery_alarm (
    input  wire clk,
    input  wire reset,
    input  wire bio_pulse_in, // From sensors
    input  wire ref_pulse_in, // From resonant_heart
    output reg  alarm_active
);

    reg [7:0] drift_cnt;
    wire drift_detected = (bio_pulse_in ^ ref_pulse_in);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            drift_cnt <= 0;
            alarm_active <= 0;
        end else begin
            if (drift_detected) begin
                if (drift_cnt < 8'hFF) drift_cnt <= drift_cnt + 1;
            end else begin
                if (drift_cnt > 0) drift_cnt <= drift_cnt - 1;
            end
            
            // Trigger alarm if drift persists for 128 cycles
            alarm_active <= (drift_cnt > 8'd128);
        end
    end

endmodule
