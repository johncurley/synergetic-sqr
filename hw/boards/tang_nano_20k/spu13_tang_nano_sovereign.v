// SPU-13 Sovereign Top-Level: Tang Nano 20K
// Objective: End-to-End Laminar Data Flow (PC -> UART -> SPU -> DISPLAY)
// Target: Gowin GW2AR-18

module spu13_tang_nano_sovereign (
    input  wire clk_27mhz,
    input  wire rst_n,
    
    // Command Artery (UART)
    input  wire uart_rx,
    
    // LCD Interface (Generic 40-pin RGB)
    output wire lcd_pclk,
    output wire lcd_hsync,
    output wire lcd_vsync,
    output wire lcd_de,
    output wire [4:0] lcd_r,
    output wire [5:0] lcd_g,
    output wire [4:0] lcd_b
);

    // --- 1. UART Reception & Word Assembly ---
    wire [7:0] rx_data;
    wire       rx_ready;
    uart_rx_mini #(
        .CLK_HZ(27000000),
        .BAUD(115200)
    ) u_uart (
        .clk(clk_27mhz),
        .rx_pin(uart_rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    reg [63:0] sovereign_word;
    reg [2:0]  byte_cnt;
    reg        word_ready;

    always @(posedge clk_27mhz or negedge rst_n) begin
        if (!rst_n) begin
            sovereign_word <= 64'h0;
            byte_cnt <= 3'd0;
            word_ready <= 1'b0;
        end else begin
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
    end

    // --- 2. Sovereign Decoder ---
    wire [7:0]  opcode;
    wire [11:0] q_a, q_b, q_c, q_d;
    wire [7:0]  energy;
    wire        trigger_draw;

    spu13_decoder u_decoder (
        .clk(clk_27mhz),
        .reset(!rst_n),
        .inst_word(sovereign_word),
        .inst_valid(word_ready),
        .opcode(opcode),
        .q_a(q_a), .q_b(q_b), .q_c(q_c), .q_d(q_d),
        .energy(energy),
        .trigger_draw(trigger_draw)
    );

    // --- 3. Scanning & Energy Projection ---
    // Simple 480x272 timing (Roughly 9MHz Pixel Clock derived from 27MHz)
    reg [1:0] clk_div;
    always @(posedge clk_27mhz) clk_div <= clk_div + 1;
    wire pclk_internal = clk_div[1];

    reg [9:0] h_cnt, v_cnt;
    always @(posedge pclk_internal or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 10'd0; v_cnt <= 10'd0;
        end else begin
            if (h_cnt == 10'd524) begin
                h_cnt <= 10'd0;
                if (v_cnt == 10'd287) v_cnt <= 10'd0;
                else v_cnt <= v_cnt + 10'd1;
            end else h_cnt <= h_cnt + 10'd1;
        end
    end

    assign lcd_hsync = (h_cnt < 10'd480);
    assign lcd_vsync = (v_cnt < 10'd272);
    assign lcd_de    = (h_cnt < 10'd480 && v_cnt < 10'd272);
    assign lcd_pclk  = pclk_internal;

    wire [7:0] dist_fixed = 8'd10;
    wire [7:0] intensity;

    vector_to_parabola u_projector (
        .clk(clk_27mhz),
        .reset(!rst_n),
        .base_energy(energy),
        .dist_to_center(dist_fixed),
        .pixel_out(intensity)
    );

    assign lcd_r = lcd_de ? intensity[7:3] : 5'd0;
    assign lcd_g = lcd_de ? intensity[7:2] : 6'd0;
    assign lcd_b = lcd_de ? intensity[7:3] : 5'd0;

endmodule
