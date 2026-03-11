// SPU-13 Whisper Transmitter (v1.0)
// Objective: 1-wire Pulse-Width Identity (PWI) for Nano Nodes.
// Mapping: 10us (Identity) -> 100us (Recovery/Leak).

module spu_whisper_tx #(
    parameter CLK_HZ = 12000000
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        sync_in,     // Trigger pulse from Cortex
    input  wire [31:0] tension_k,   // Local Curvature K
    input  wire        fault_in,    // Local Recovery status
    output reg         pulse_out
);

    // Map tension to pulse duration: 120 cycles (10us) to 1200 cycles (100us)
    // Baseline (Identity) = 120 cycles
    // Fault (Recovery) = 1200 cycles
    wire [15:0] target_width = fault_in ? 16'd1200 : (16'd120 + tension_k[15:6]);

    reg [15:0] counter;
    reg busy;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pulse_out <= 0;
            counter <= 0;
            busy <= 0;
        end else if (sync_in && !busy) begin
            busy <= 1;
            counter <= 0;
            pulse_out <= 1;
        end else if (busy) begin
            if (counter < target_width) begin
                counter <= counter + 1;
            end else begin
                pulse_out <= 0;
                busy <= 0;
            end
        end
    end

endmodule
