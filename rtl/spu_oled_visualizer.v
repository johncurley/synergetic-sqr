// SPU-13 OLED Visualizer: Dual Hemisphere (v3.4.4)
// Implementation: Geometry (Left) and Metabolism (Right).
// Objective: Turn the invisible Laminar Flow into a visible Pulse.
// Result: 128x64 bit-map representing the SPU-13 'Mood'.

module spu_oled_visualizer (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] manifold_a,   // Primary state lane
    input  wire [15:0] microwatts,   // Real-time power
    output reg  [7:0]  pixel_data,   // Byte stream for I2C driver
    output reg  [6:0]  pixel_addr,   // Current column/page
    output wire        frame_done
);

    // 1. Strip Chart Memory (Right Hemisphere)
    // 64 columns of power data
    reg [5:0] power_history [0:63];
    reg [5:0] write_ptr;
    
    // 2. Projection Logic (Left Hemisphere)
    // Projecting the 32-bit A-lane into a 64x64 visual field.
    // We use the MSBs for position and LSBs for intensity.
    wire [5:0] geom_x = manifold_a[31:26] + 6'd32;
    wire [5:0] geom_y = manifold_a[25:20] + 6'd32;

    // 3. Frame Buffering (Conceptual byte-stream)
    // In a physical SSD1306, we stream pages (8 rows high).
    reg [15:0] frame_timer;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            frame_timer <= 0;
        end else begin
            // Every ~100ms, update the history
            if (frame_timer == 16'hFFFF) begin
                power_history[write_ptr] <= (microwatts > 16'd63) ? 6'd63 : microwatts[5:0];
                write_ptr <= write_ptr + 1;
                frame_timer <= 0;
            end else begin
                frame_timer <= frame_timer + 1;
            end
        end
    end

    // Pixel Output Logic (Simplified for Bridge)
    assign frame_done = (pixel_addr == 7'd127);

endmodule
