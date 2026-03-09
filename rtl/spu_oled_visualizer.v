// SPU-13 OLED Visualizer: Dual Hemisphere (v3.4.11)
// Implementation: Geometry (Left) and Metabolism (Right).
// Objective: Format 128x64 data for SSD1306 Horizontal Mode.
// Result: 1024 bytes per frame cycle.

module spu_oled_visualizer (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] manifold_a,
    input  wire [15:0] microwatts,
    output reg  [7:0]  pixel_data,
    output reg  [9:0]  pixel_idx,    // 0-1023 bytes
    output reg         frame_sync
);

    // Internal Page/Column Mapping
    // Page: 0-7 (8 rows each)
    // Column: 0-127
    wire [2:0] page = pixel_idx[9:7];
    wire [6:0] col  = pixel_idx[6:0];

    // Strip Chart History (64 columns)
    reg [5:0] power_history [0:63];
    reg [5:0] write_ptr;
    reg [15:0] update_timer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0; update_timer <= 0;
            pixel_idx <= 0; frame_sync <= 0;
        end else begin
            // 1. Telemetry Update (every ~100ms)
            if (update_timer == 16'hFFFF) begin
                power_history[write_ptr] <= (microwatts > 16'd63) ? 6'd63 : microwatts[5:0];
                write_ptr <= write_ptr + 1;
                update_timer <= 0;
            end else begin
                update_timer <= update_timer + 1;
            end

            // 2. Data Sequencing
            pixel_idx <= pixel_idx + 1;
            frame_sync <= (pixel_idx == 1023);

            // 3. Pixel Mapping
            if (col < 64) begin
                // LEFT HEMISPHERE: Geometry (Simple projection)
                // Drawing a single 'pixel' for the A-axis string
                pixel_data <= (page == col[5:3]) ? (8'h01 << col[2:0]) : 8'h00;
            end else begin
                // RIGHT HEMISPHERE: Metabolism (Strip Chart)
                // col[5:0] indexes power_history
                pixel_data <= (power_history[col-64] >> page) ? 8'hFF : 8'h00;
            end
        end
    end

endmodule
