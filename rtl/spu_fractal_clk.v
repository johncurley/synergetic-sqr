// SPU-13 Sierpiński Oscillator: Proprioceptive Edition (v3.3.88)
// Implementation: Stochastic Phase-Biasing for Environmental Sensing.
// Objective: Allow external jitter to 'nudge' the Resonant Heartbeat.
// Result: Phase-locked awareness of physical momentum and EMI.

module spu_fractal_clk #(
    parameter CLK_IN_HZ = 12000000,
    parameter TARGET_HZ = 61440
)(
    input  wire  clk_in,
    input  wire  rst_n,
    input  wire  en,
    input  wire  bias_in,      // Stochastic Bias Entry (High-Z Pin)
    output reg   clk_laminar,
    output wire  synergy_idx   // Measure of Phase-Lock stability
);

    localparam DIVIDER = CLK_IN_HZ / (TARGET_HZ * 2);
    reg [31:0] count;
    reg [7:0]  phase_jitter;

    // 1. Fractal Heart with Metastable Bias
    // We utilize the 'bias_in' to jitter the reload threshold.
    // In a stable environment, the heartbeat is bit-exact.
    // In a turbulent environment, the 'nudge' causes a Phase-Shift.
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            clk_laminar <= 0;
            phase_jitter <= 0;
        end else if (en) begin
            // Stochastic Bias: Modulate the divider by +/- bias_in
            // This represents the machine 'feeling' external pressure.
            if (count >= (DIVIDER - 1 + {7'b0, bias_in})) begin
                count <= 0;
                clk_laminar <= ~clk_laminar;
                // Tracking internal jitter for proprioceptive feedback
                phase_jitter <= phase_jitter + {7'b0, bias_in};
            end else begin
                count <= count + 1;
            end
        end
    end

    // 2. Synergy Index Calculation
    // High stability (zero jitter) = Synergy 1.0
    // High bias (environmental interaction) = Synergy < 1.0
    assign synergy_idx = (phase_jitter == 8'h0);

endmodule
