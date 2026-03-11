// uart_tx_mini.v - Minimalist UART Transmitter
module uart_tx_mini #(
    parameter CLK_HZ = 12000000,
    parameter BAUD   = 115200
)(
    input  wire clk,
    input  wire tx_start,
    input  wire [7:0] tx_data,
    output reg  tx_pin,
    output wire busy
);
    localparam BIT_CYCLES = CLK_HZ / BAUD;
    
    reg [3:0] bit_index = 0;
    reg [15:0] cycle_cnt = 0;
    reg [9:0] shift_reg = 10'b1111111111;

    assign busy = (bit_index != 0);

    initial tx_pin = 1'b1;

    always @(posedge clk) begin
        if (!busy) begin
            if (tx_start) begin
                shift_reg <= {1'b1, tx_data, 1'b0};
                bit_index <= 10;
                cycle_cnt <= 0;
            end
        end else begin
            if (cycle_cnt < BIT_CYCLES - 1) begin
                cycle_cnt <= cycle_cnt + 1;
            end else begin
                cycle_cnt <= 0;
                tx_pin <= shift_reg[0];
                shift_reg <= {1'b1, shift_reg[9:1]};
                bit_index <= bit_index - 1;
            end
        end
    end
endmodule
