// SPU-13 Sovereign Top-Level: iCEsugar (UP5K)
// Objective: End-to-End Laminar Data Flow (PC -> UART -> SPU -> DISPLAY)
// Logic: Unpacks 64-bit Sovereign Words and drives a Parallel RGB Interface.

module spu13_icesugar_sovereign (
    input  wire clk_12mhz,
    input  wire rst_n,
    
    // Command Artery (UART)
    input  wire uart_rx,
    
    // Parallel Vision (PMOD C + PMOD A)
    output wire pclk,
    output wire hsync,
    output wire vsync,
    output wire de,
    output wire [3:0] r,
    output wire [3:0] g,
    output wire [3:0] b
);

    // --- 1. UART Reception & Word Assembly ---
    wire [7:0] rx_data;
    wire       rx_ready;
    uart_rx_mini #(
        .CLK_HZ(12000000),
        .BAUD(115200)
    ) u_uart (
        .clk(clk_12mhz),
        .rx_pin(uart_rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    reg [63:0] sovereign_word;
    reg [2:0]  byte_cnt;
    reg        word_ready;

    always @(posedge clk_12mhz or negedge rst_n) begin
        if (!rst_n) begin
            sovereign_word <= 64'h0;
            byte_cnt <= 3'd0;
            word_ready <= 1'b0;
        end else begin
            word_ready <= 1'b0;
            if (rx_ready) begin
                // Shift in bytes (Big-endian from PC)
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
        .clk(clk_12mhz),
        .reset(!rst_n),
        .inst_word(sovereign_word),
        .inst_valid(word_ready),
        .opcode(opcode),
        .q_a(q_a_raw), .q_b(q_b_raw), .q_c(q_c_raw), .q_d(q_d_raw),
        .energy(energy),
        .trigger_draw(trigger_draw)
    );

    // --- 2.5 Anneal Stabilizer ---
    wire [11:0] q_a_raw, q_b_raw, q_c_raw, q_d_raw;
    wire [11:0] q_a, q_b, q_c, q_d;

    spu13_anneal_stabilizer u_anneal_a ( .clk(clk_12mhz), .reset(!rst_n), .raw_coord(q_a_raw), .temp_scale(4'd1), .annealed_coord(q_a) );
    spu13_anneal_stabilizer u_anneal_b ( .clk(clk_12mhz), .reset(!rst_n), .raw_coord(q_b_raw), .temp_scale(4'd1), .annealed_coord(q_b) );
    spu13_anneal_stabilizer u_anneal_c ( .clk(clk_12mhz), .reset(!rst_n), .raw_coord(q_c_raw), .temp_scale(4'd1), .annealed_coord(q_c) );
    spu13_anneal_stabilizer u_anneal_d ( .clk(clk_12mhz), .reset(!rst_n), .raw_coord(q_d_raw), .temp_scale(4'd1), .annealed_coord(q_d) );


    // --- 3. Scanning & Energy Projection ---
    // Simple 240x240 timing (Slow 12MHz Scanout)
    reg [9:0] h_cnt, v_cnt;
    always @(posedge clk_12mhz or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 10'd0; v_cnt <= 10'd0;
        end else begin
            if (h_cnt == 10'd399) begin
                h_cnt <= 10'd0;
                if (v_cnt == 10'd299) v_cnt <= 10'd0;
                else v_cnt <= v_cnt + 10'd1;
            end else h_cnt <= h_cnt + 10'd1;
        end
    end

    assign hsync = (h_cnt < 10'd320);
    assign vsync = (v_cnt < 10'd280);
    assign de    = (h_cnt < 10'd240 && v_cnt < 10'd240);
    assign pclk  = clk_12mhz;

    // Distance Calculation (Placeholder for real IVM logic)
    // In a full implementation, we'd check distance from current (h,v) to the Quadray vector
    wire [7:0] dist_fixed = 8'd10; // For test
    wire [7:0] intensity;

    vector_to_parabola u_projector (
        .clk(clk_12mhz),
        .reset(!rst_n),
        .base_energy(energy),
        .dist_to_center(dist_fixed),
        .pixel_out(intensity)
    );

    // Drive RGB444 Pins
    assign r = de ? intensity[7:4] : 4'd0;
    assign g = de ? intensity[7:4] : 4'd0;
    assign b = de ? intensity[7:4] : 4'd0;

endmodule
