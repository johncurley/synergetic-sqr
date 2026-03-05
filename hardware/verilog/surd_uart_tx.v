// SPU-13 UART Transmitter (v2.9.26)
// Converts bit-exact Surd registers to serial data for the Bloom View UI.
// Logic: Non-blocking Laminar Telemetry at 115,200 Baud.

module surd_uart_tx #(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire [31:0] data_in, // The Surd Register component
    input  wire        start,
    output reg         tx,
    output reg         ready
);

    localparam WAIT_CYCLES = CLK_FREQ / BAUD_RATE;
    reg [31:0] shift_reg;
    reg [15:0] count;
    reg [5:0]  bit_idx;

    initial begin
        tx = 1'b1;
        ready = 1'b1;
    end

    always @(posedge clk) begin
        if (ready && start) begin
            shift_reg <= data_in;
            ready <= 1'b0;
            bit_idx <= 0;
            count <= 0;
        end else if (!ready) begin
            if (count < WAIT_CYCLES) begin
                count <= count + 1;
            end else begin
                count <= 0;
                if (bit_idx == 0) tx <= 1'b0; // Start bit
                else if (bit_idx <= 32) tx <= shift_reg[bit_idx-1]; // 32-bit data
                else if (bit_idx == 33) tx <= 1'b1; // Stop bit
                
                if (bit_idx < 33) bit_idx <= bit_idx + 1;
                else ready <= 1'b1;
            end
        end
    end
endmodule
