// SPU-13 Sierpiński Oscillator: Proprioceptive Edition (v3.4.21)
// Implementation: Stochastic Phase-Biasing & Frequency Homeostasis.
// Objective: Allow the Thalamus to regulate the Resonant Heartbeat.
// Result: Real-time frequency adaptation to metabolic pressure.

module spu_fractal_clk #(
    parameter CLK_IN_HZ = 12000000,
    parameter TARGET_HZ = 61440
)(
    input  wire  clk_in,
    input  wire  rst_n,
    input  wire  en,
    input  wire  bias_in,      // Stochastic Bias (Physical Antenna)
    input  wire [3:0] freq_bias,// Metabolic Bias (Thalamic Feedback)
    output reg   clk_laminar,
    output wire  synergy_idx
);

    localparam DIVIDER = CLK_IN_HZ / (TARGET_HZ * 2);
    reg [31:0] count;
    reg [7:0]  phase_jitter;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            clk_laminar <= 0;
            phase_jitter <= 0;
        end else if (en) begin
            // Total Bias = Stochastic Antenna Jitter + Metabolic Frequency Shift
            if (count >= (DIVIDER - 1 + {7'b0, bias_in} + {28'b0, freq_bias})) begin
                count <= 0;
                clk_laminar <= ~clk_laminar;
                phase_jitter <= phase_jitter + {7'b0, bias_in};
            end else begin
                count <= count + 1;
            end
        end
    end

    assign synergy_idx = (phase_jitter == 8'h0);

endmodule
