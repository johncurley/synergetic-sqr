// SPU-13 Laminar Physical Layer (v1.0)
// Target: iCE40LP1K (Nano Sentinel)
// Objective: 60-Degree Phase-Resonant Handshake.
// Feature: Addresses nodes via Radial Geometry (a,b,c,d).

module spu_laminar_phy (
    input  wire        clk,
    input  wire        reset,
    input  wire        heartbeat_in, // 61.44 kHz Master Pulse
    input  wire [1:0]  target_axis,  // 00:A, 01:B, 10:C, 11:D
    input  wire        is_transmitting,
    output reg         artery_out,
    output wire        axis_match    // High if Artery pulse matches target_axis
);

    // 1. Phase Counter (0 to 359 'Degrees' per heartbeat)
    // 61.44 kHz heartbeat / 360 = ~170 Hz per degree resolution
    // We simplify to 4 primary phases (0, 60, 120, 180) for the Nano
    reg [7:0] phase_cnt;
    always @(posedge clk or posedge reset) begin
        if (reset) phase_cnt <= 0;
        else if (heartbeat_in) phase_cnt <= 0;
        else phase_cnt <= phase_cnt + 1;
    end

    // 2. Pulse Generation (Transmit)
    // We send a short pulse at the specific geometric offset
    wire [7:0] tx_offset = (target_axis == 2'b00) ? 8'd0  : // 0 deg
                           (target_axis == 2'b01) ? 8'd32 : // 60 deg approx
                           (target_axis == 2'b10) ? 8'd64 : // 120 deg approx
                                                    8'd96 ; // 180 deg approx

    always @(posedge clk) begin
        if (is_transmitting && phase_cnt == tx_offset)
            artery_out <= 1'b1;
        else
            artery_out <= 1'b0;
    end

    // 3. Pulse Detection (Receive)
    // Matches incoming Artery spikes against local axis
    assign axis_match = !is_transmitting && (phase_cnt == tx_offset);

endmodule
