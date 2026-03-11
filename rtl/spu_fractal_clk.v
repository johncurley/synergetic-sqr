// SPU-13 Biological Heartbeat (v4.0.0 Phi-Gated)
// Target: Unified SPU-13 Fleet
// Objective: Replace rigid "Cubic" clocks with a Recursive Pulse governed by Phi (phi).
// Result: Non-linear temporal flow for Phase Conjugation.

module spu_fractal_clk #(
    parameter CLK_IN_HZ = 12000000
)(
    input  wire  clk_in,
    input  wire  rst_n,
    input  wire  en,
    output wire  phi_heartbeat, // The non-linear "Pulse of Sanity"
    output reg   clk_laminar    // Steady divided clock for peripherals
);

    // --- 1. The Laminar Rhythm (Fibonacci Sequence) ---
    // Instead of a steady metronome, we pulse at 8, 13, 21 within a 34-cycle frame.
    reg [7:0] phi_cnt;
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) phi_cnt <= 0;
        else if (en) begin
            if (phi_cnt == 34) phi_cnt <= 0;
            else phi_cnt <= phi_cnt + 1;
        end
    end

    // The pulse fires only at the Fibonacci intersections
    assign phi_heartbeat = (phi_cnt == 8 || phi_cnt == 13 || phi_cnt == 21);

    // --- 2. Steady Baseline (Peripheral Support) ---
    // A standard 61.44 kHz pulse for OLED and UART stability.
    localparam DIVIDER = CLK_IN_HZ / 122880; 
    reg [31:0] count;
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            clk_laminar <= 0;
        end else if (en) begin
            if (count >= (DIVIDER - 1)) begin
                count <= 0;
                clk_laminar <= ~clk_laminar;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
