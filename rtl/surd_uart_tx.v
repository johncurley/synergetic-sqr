// SPU-13 UART Transmitter (v3.1.10)
// Sends 32-bit Surd registers as four 8-bit UART frames (8-N-1).
// Logic: Little-Endian transmission for direct ingestion by Bloom View UI.

module surd_uart_tx #(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] data_in, 
    input  wire        start,
    output reg         tx,
    output wire        ready
);

    localparam WAIT_CYCLES = CLK_FREQ / BAUD_RATE;
    
    reg [31:0] buffer;
    reg [15:0] count;
    reg [3:0]  byte_idx; // 0-3 for data bytes
    reg [3:0]  bit_idx;  // 0-9 for start, 8-data, stop
    reg        active;

    assign ready = !active;

    initial begin
        tx = 1'b1;
        active = 1'b0;
    end

    always @(posedge clk) begin
        if (reset) begin
            tx <= 1'b1;
            active <= 1'b0;
            count <= 0;
            byte_idx <= 0;
            bit_idx <= 0;
        end else if (!active && start) begin
            buffer <= data_in;
            active <= 1'b1;
            byte_idx <= 0;
            bit_idx <= 0;
            count <= 0;
        end else if (active) begin
            if (count < WAIT_CYCLES - 1) begin
                count <= count + 1;
            end else begin
                count <= 0;
                case (bit_idx)
                    0: tx <= 1'b0; // Start bit
                    1,2,3,4,5,6,7,8: begin
                        // Send bits of current byte
                        tx <= buffer[byte_idx*8 + (bit_idx-1)];
                    end
                    9: tx <= 1'b1; // Stop bit
                endcase

                if (bit_idx < 9) begin
                    bit_idx <= bit_idx + 1;
                end else begin
                    bit_idx <= 0;
                    if (byte_idx < 3) begin
                        byte_idx <= byte_idx + 1;
                    end else begin
                        active <= 1'b0; // Done with all 4 bytes
                    end
                end
            end
        end
    end
endmodule
