// SPU-13 I/O Bridge (v3.3.9)
// Dual-Domain Telemetry: Operates at clk_phys for UART stability,
// but captures data synchronized to clk_resonant.

module spu_io_bridge #(
    parameter CLK_PHYS_HZ = 12000000,
    parameter BAUD_RATE   = 115200
)(
    input  wire         clk_phys,     // High-speed base oscillator
    input  wire         clk_resonant, // 61.44 kHz manifold heartbeat
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
    reg  clk_resonant_last;
    
    // 1. Edge Detection: Capture state only on resonant ticks
    always @(posedge clk_phys) begin
        if (reset) begin
            uart_start <= 1'b0;
            clk_resonant_last <= 1'b0;
        end else begin
            clk_resonant_last <= clk_resonant;
            // Trigger UART transmission on every rising edge of the resonant clock
            if (clk_resonant && !clk_resonant_last && uart_ready)
                uart_start <= 1'b1;
            else
                uart_start <= 1'b0;
        end
    end

    // 2. Surd Telemetry Transmitter (Driven by clk_phys)
    surd_uart_tx #(
        .CLK_FREQ(CLK_PHYS_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk(clk_phys),
        .reset(reset),
        .data_in(spu_reg_in[31:0]), // Stream the A-component
        .start(uart_start),
        .tx(serial_tx),
        .ready(uart_ready)
    );

    // 3. Physical Status Mapping
    assign led_status  = {fault_detected, spu_reg_in[2:0]};
    assign pmod_ja_out = spu_reg_in[15:8];
    assign sw_control  = 4'b0;

endmodule
