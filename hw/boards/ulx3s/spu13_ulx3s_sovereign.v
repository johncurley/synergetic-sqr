// SPU-13 Sovereign Top-Level: ULX3S
// Objective: End-to-End Laminar Data Flow (PC -> UART -> SPU -> DISPLAY)
// Target: Lattice ECP5

module spu13_ulx3s_sovereign (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    
    // Command Artery (UART)
    input  wire ftdi_txd, // RX from FPGA perspective
    
    // Parallel Vision (Digital Video / GPDI)
    output wire [3:0] gpdi_dp,
    output wire [3:0] gpdi_dn
);

    // --- 1. UART Reception & Word Assembly ---
    wire [7:0] rx_data;
    wire       rx_ready;
    uart_rx_mini #(
        .CLK_HZ(25000000),
        .BAUD(115200)
    ) u_uart (
        .clk(clk_25mhz),
        .rx_pin(ftdi_txd),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    reg [63:0] sovereign_word;
    reg [2:0]  byte_cnt;
    reg        word_ready;

    always @(posedge clk_25mhz) begin
        word_ready <= 1'b0;
        if (rx_ready) begin
            sovereign_word <= {sovereign_word[55:0], rx_data};
            if (byte_cnt == 3'd7) begin
                byte_cnt <= 3'd0;
                word_ready <= 1'b1;
            end else begin
                byte_cnt <= byte_cnt + 3'd1;
            end
        end
    end

    // --- 2. Sovereign Decoder ---
    wire [7:0]  opcode;
    wire [11:0] q_a, q_b, q_c, q_d;
    wire [7:0]  energy;
    wire        trigger_draw;

    spu13_decoder u_decoder (
        .clk(clk_25mhz),
        .reset(btn[0]),
        .inst_word(sovereign_word),
        .inst_valid(word_ready),
        .opcode(opcode),
        .q_a(q_a), .q_b(q_b), .q_c(q_c), .q_d(q_d),
        .energy(energy),
        .trigger_draw(trigger_draw)
    );

    // --- 3. Scanning & Energy Projection ---
    // Placeholder for real DVI/GPDI serialization
    // ULX3S usually uses a dedicated DDR serializer for video.
    // For now, we project intensity to a placeholder internal signal.
    wire [7:0] dist_fixed = 8'd10;
    wire [7:0] intensity;

    vector_to_parabola u_projector (
        .clk(clk_25mhz),
        .reset(btn[0]),
        .base_energy(energy),
        .dist_to_center(dist_fixed),
        .pixel_out(intensity)
    );

    // Placeholder: Constant diff outputs to indicate activity
    assign gpdi_dp = {intensity[7], 3'b0};
    assign gpdi_dn = ~gpdi_dp;

endmodule
