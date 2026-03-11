// SPU-13 Whisper Receiver (v1.0)
// Objective: Decode 1-wire PWI 'Whispers' into Davis Metrics.
// Output: Reconstructed remote tension and fault status.

module spu_whisper_rx #(
    parameter CLK_HZ = 12000000
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        pulse_in,
    output reg [15:0]  remote_tension,
    output reg         remote_fault,
    output reg         data_ready
);

    reg [15:0] counter;
    reg last_pulse;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            remote_tension <= 0;
            remote_fault <= 0;
            data_ready <= 0;
            counter <= 0;
            last_pulse <= 0;
        end else begin
            last_pulse <= pulse_in;
            data_ready <= 0;

            if (pulse_in) begin
                counter <= counter + 1;
            end else if (last_pulse && !pulse_in) begin
                // Falling edge: End of 'Whisper'
                // Decode: 1200+ cycles = Fault
                if (counter > 1100) begin
                    remote_fault <= 1;
                    remote_tension <= 16'hFFFF;
                end else begin
                    remote_fault <= 0;
                    remote_tension <= (counter > 120) ? (counter - 120) : 0;
                end
                data_ready <= 1;
                counter <= 0;
            end
        end
    end

endmodule
