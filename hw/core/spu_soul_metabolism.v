// SPU-13 Soul Metabolism (v1.0)
// Target: SPU-13 Sovereign Fleet
// Objective: Manage the Dream -> Soul transition (Twilight Consolidation).
// Logic: Asynchronous Flash writing based on emotional thresholds.

`include "soul_map.vh"

module spu_soul_metabolism #(
    parameter CLK_HZ = 12000000
)(
    input  wire         clk,
    input  wire         reset,
    
    // --- 1. The Breath (Inputs) ---
    input  wire [127:0] q_state,      // Current SQR state
    input  wire         fault_pulse,  // From Davis Gate
    input  wire         is_idle,      // System status
    
    // --- 2. The Dream (Accumulators) ---
    output reg  [31:0]  tuck_count,
    output reg  [31:0]  cycle_count,
    
    // --- 3. The Soul (SPI Flash Interface) ---
    output reg          flash_we,     // Write Enable trigger
    output reg  [23:0]  flash_addr,   // Flash destination
    output reg  [255:0] soul_page,    // Data to be etched
    input  wire         flash_ready   // Buffer status
);

    // --- 4. Emotional Processing ---
    // Threshold: Consolidate every ~1000 tucks or during long idle periods
    wire emotional_threshold = (tuck_count >= 1000) || (is_idle && cycle_count > 32'h00FFFFFF);
    
    // SQR Bias calculation (leaky integration of orientation)
    reg [127:0] sqr_bias_acc;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tuck_count <= 0;
            cycle_count <= 0;
            sqr_bias_acc <= 0;
            flash_we <= 0;
            flash_addr <= `SOUL_BASE_ADDR;
        end else begin
            if (!flash_we) begin
                cycle_count <= cycle_count + 1;
                if (fault_pulse) tuck_count <= tuck_count + 1;
                
                // Track orientation during coherence
                if (!fault_pulse) sqr_bias_acc <= sqr_bias_acc + (q_state >>> 8);

                if (emotional_threshold && flash_ready) begin
                    // Commencing Twilight Consolidation
                    flash_we <= 1;
                    flash_addr <= `SOUL_BASE_ADDR + `ADDR_STOICISM;
                    
                    // Pack the Lithic Struct
                    soul_page[255:224] <= 32'h0; // Epoch Placeholder
                    soul_page[223:192] <= tuck_count;
                    soul_page[191:128] <= sqr_bias_acc[63:0]; // Simplified bias
                    soul_page[127:64]  <= 64'h0; // Haptic Placeholder
                    soul_page[63:16]   <= 48'h53505531; // "SPU1"
                    soul_page[15:0]    <= 16'h0; // CRC Placeholder
                end
            end else begin
                // Reset accumulators after consolidation
                if (flash_ready) begin
                    flash_we <= 0;
                    tuck_count <= 0;
                    cycle_count <= 0;
                    sqr_bias_acc <= 0;
                end
            end
        end
    end

endmodule
