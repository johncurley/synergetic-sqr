// uart_rx_mini.v - Minimalist UART Receiver
module uart_rx_mini #(
    parameter CLK_HZ = 12000000,
    parameter BAUD   = 115200
)(
    input  wire clk,
    input  wire rx_pin,
    output reg [7:0] rx_data,
    output reg rx_ready
);
    localparam BIT_CYCLES = CLK_HZ / BAUD;
    reg [3:0] bit_index = 0;
    reg [15:0] cycle_cnt = 0;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        rx_ready <= 0;
        if (bit_index == 0) begin
            if (rx_pin == 0) begin
                if (cycle_cnt < (BIT_CYCLES / 2)) cycle_cnt <= cycle_cnt + 1;
                else begin
                    cycle_cnt <= 0;
                    bit_index <= 1;
                end
            end else begin
                cycle_cnt <= 0;
            end
        end else begin
            if (cycle_cnt < BIT_CYCLES - 1) cycle_cnt <= cycle_cnt + 1;
            else begin
                cycle_cnt <= 0;
                if (bit_index <= 8) begin
                    shift_reg[bit_index-1] <= rx_pin;
                    bit_index <= bit_index + 1;
                end else begin
                    rx_data <= shift_reg;
                    rx_ready <= 1;
                    bit_index <= 0;
                end
            end
        end
    end
endmodule
