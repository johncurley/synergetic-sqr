// SPU-13 Universal Sierpiński Fractal Oscillator (v3.1.36)
// Implementation: NCO-based frequency divider for 61.44 kHz resonance.
// Logic: Fractional phase accumulation to maintain geometric average.

module spu_fractal_clk #(
    parameter CLK_IN_HZ = 12000000,
    parameter CLK_OUT_HZ = 61440
)(
    input  wire clk_in,
    input  wire rst_n,
    output reg  clk_laminar
);

    // Calculate NCO Step: (Fout * 2^32) / Fin
    // We use 64-bit math for the localparam calculation to ensure precision.
    localparam [31:0] STEP = (64'(CLK_OUT_HZ) << 32) / CLK_IN_HZ;

    reg [31:0] phase_acc;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc <= 32'b0;
            clk_laminar <= 1'b0;
        end else begin
            phase_acc <= phase_acc + STEP;
            // The MSB overflow creates the 50% duty cycle resonant pulse
            if (phase_acc < STEP) begin
                clk_laminar <= ~clk_laminar;
            end
        end
    end

endmodule
