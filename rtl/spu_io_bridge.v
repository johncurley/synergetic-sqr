// SPU-13 I/O Bridge (v3.1.10)
// Manages serial telemetry and status LEDs for the physical fabric.

module spu_io_bridge #(
    parameter CLK_FREQ = 100000000
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] spu_reg_in,
    input  wire         fault_detected,
    output wire [3:0]   led_status,
    output wire [7:0]   pmod_ja_out,
    output wire [3:0]   sw_control,
    input  wire         serial_rx,
    output wire         serial_tx
);

    wire uart_ready;
    reg  uart_start;
    
    // Auto-trigger transmission when ready
    always @(posedge clk) begin
        if (reset) begin
            uart_start <= 1'b0;
        end else begin
            uart_start <= uart_ready; 
        end
    end

    // 1. Surd Telemetry Transmitter (8-N-1, 115200 Baud)
    surd_uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(115200)
    ) u_tx (
        .clk(clk),
        .reset(reset),
        .data_in(spu_reg_in[31:0]), // Stream the A-component of the first register
        .start(uart_start),
        .tx(serial_tx),
        .ready(uart_ready)
    );

    // 2. Physical Status Mapping
    assign led_status  = {fault_detected, spu_reg_in[2:0]};
    assign pmod_ja_out = spu_reg_in[15:8];
    assign sw_control  = 4'b0; // Reserved for future command-sync

endmodule
