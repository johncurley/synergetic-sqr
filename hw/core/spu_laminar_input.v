// SPU-13 Laminar Input Driver (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Zero-Latency, Interrupt-Driven Synchronous Input.
// Logic: 2-Wire (Clock/Data) Push-Metabolism.

module spu_laminar_input (
    input  wire         clk,
    input  wire         reset,
    
    // Physical Interface (from Peripheral)
    input  wire         l_clk,
    input  wire         l_dat,
    
    // Internal Artery Strike
    output reg  [15:0]  vector_out,
    output reg          strike_valid
);

    // --- 1. Synchronization & Edge Detection ---
    reg [2:0] clk_sync;
    always @(posedge clk) clk_sync <= {clk_sync[1:0], l_clk};
    wire falling_edge = (clk_sync[2:1] == 2'b10);

    // --- 2. Shift Register (16-bit Vector) ---
    reg [3:0]  bit_cnt;
    reg [15:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            strike_valid <= 0;
            vector_out <= 0;
        end else begin
            if (falling_edge) begin
                shift_reg <= {l_dat, shift_reg[15:1]};
                if (bit_cnt == 15) begin
                    bit_cnt <= 0;
                    vector_out <= {l_dat, shift_reg[15:1]};
                    strike_valid <= 1;
                end else begin
                    bit_cnt <= bit_cnt + 1;
                    strike_valid <= 0;
                end
            end else begin
                strike_valid <= 0;
            end
        end
    end

endmodule
