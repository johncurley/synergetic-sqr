// SPU-13 Universal Sierpiński Fractal Oscillator (v3.3.4)
// Implementation: NCO-based frequency divider for 61.44 kHz resonance.
// Logic: Fractional phase accumulation with Enable-Gating (The Throttle).

module spu_fractal_clk #(
    parameter CLK_IN_HZ = 12000000,
    parameter CLK_OUT_HZ = 61440
)(
    input  wire clk_in,
    input  wire rst_n,
    input  wire en,          // Enable Gating
    output reg  clk_laminar
);

    // Calculate NCO Step: (Fout * 2^32) / Fin
    localparam [31:0] STEP = (64'(CLK_OUT_HZ) << 32) / CLK_IN_HZ;

    reg [31:0] phase_acc;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= 32'b0;
            clk_laminar <= 1'b0;
        end else if (en) begin
            phase_acc <= phase_acc + STEP;
            // The MSB overflow creates the 50% duty cycle resonant pulse
            if (phase_acc < STEP) begin
                clk_laminar <= ~clk_laminar;
            end
        end else begin
            // Hold state when disabled to prevent phase jitter
            phase_acc <= phase_acc;
            clk_laminar <= 1'b0;
        end
    end

endmodule
