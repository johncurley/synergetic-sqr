// SPU-13 Tetra-Board Decoder (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Decode 16-bit Quadray Vectors into Lithic-L Chords.
// Logic: Threshold-based chording logic for analog clusters.

module spu_tetra_decoder (
    input  wire         clk,
    input  wire         reset,
    input  wire [15:0]  vector_in,
    input  wire         strike_valid,
    
    // Command Interface
    output reg          cmd_flush,
    output reg          cmd_sync,
    output reg          cmd_leap,
    output reg  [3:0]   intensity_out
);

    // Extraction of Axis Magnitudes
    wire [3:0] mag_a = vector_in[3:0];
    wire [3:0] mag_b = vector_in[7:4];
    wire [3:0] mag_c = vector_in[11:8];
    wire [3:0] mag_d = vector_in[15:12];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cmd_flush <= 0; cmd_sync <= 0; cmd_leap <= 0;
            intensity_out <= 0;
        end else if (strike_valid) begin
            // 1. Identity Strike (A+B+C+D high) -> Flush
            cmd_flush <= (mag_a > 8 && mag_b > 8 && mag_c > 8 && mag_d > 8);
            
            // 2. Resonant Leap (A+C high) -> Leap
            cmd_leap  <= (mag_a > 10 && mag_c > 10 && mag_b < 4 && mag_d < 4);
            
            // 3. Simple Pulse (Any axis) -> Sync
            cmd_sync  <= (mag_a > 4 || mag_b > 4 || mag_c > 4 || mag_d > 4);
            
            // Output highest magnitude for haptic feedback
            intensity_out <= (mag_a > mag_b) ? mag_a : mag_b;
        end else begin
            cmd_flush <= 0; cmd_sync <= 0; cmd_leap <= 0;
        end
    end

endmodule
