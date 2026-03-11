// SPU-13 Dream Log (v1.0)
// Target: iCE40UP5K (Big Brother Cortex)
// Objective: Long-term Sanity History + Adaptive Tolerance.
// Logic: Uses 128KB SPRAM as a Circular Buffer for Manifold Tension.

module spu_dream_log (
    input  wire         clk,
    input  wire         reset,
    input  wire [15:0]  current_tension, // Aggregate K
    input  wire         log_trigger,     // Pulse to record
    output reg  [31:0]  learned_tau_q,   // Dynamically adjusted threshold
    output wire [15:0]  history_data,    // For OLED playback
    input  wire [15:0]  playback_addr
);

    // --- 1. The Standing Wave Buffer (128KB SPRAM) ---
    reg [15:0] write_ptr;
    wire [15:0] spram_data_out;
    
    spu_gram_controller u_spram (
        .clk(clk), .reset(reset),
        .addr(playback_mode ? playback_addr : write_ptr),
        .data_in(current_tension),
        .write_en(log_trigger && !playback_mode),
        .data_out(spram_data_out),
        .ready()
    );
    assign history_data = spram_data_out;

    // --- 2. Adaptive Sanity Logic ---
    // We maintain a running sum of the last 256 tensions to calculate "Stress Trends"
    reg [23:0] tension_sum;
    reg [7:0]  trend_cnt;
    reg playback_mode;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            tension_sum <= 0;
            trend_cnt <= 0;
            learned_tau_q <= 32'h04000000; // Default baseline
            playback_mode <= 0;
        end else if (log_trigger) begin
            write_ptr <= write_ptr + 1;
            
            // Accumulate trend data
            tension_sum <= tension_sum + current_tension;
            trend_cnt <= trend_cnt + 1;
            
            if (trend_cnt == 255) begin
                // Every 256 logs, we "Learn" the environment.
                // If average tension is high, we widen the gasket (Higher tau)
                // If average tension is low, we tighten the gasket (Lower tau)
                if (tension_sum[23:8] > 16'h4000) 
                    learned_tau_q <= learned_tau_q + 32'h00100000; // Relax
                else if (learned_tau_q > 32'h01000000)
                    learned_tau_q <= learned_tau_q - 32'h00100000; // Tighten
                
                tension_sum <= 0;
                trend_cnt <= 0;
            end
        end
    end

endmodule
