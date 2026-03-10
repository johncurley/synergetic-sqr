// SPU-13 NANO BALANCER (v1.0)
// Target: iCE40UP5K (iCeSugar Nano)
// Objective: Monadic Laplacian Relaxation for fluid-like self-stabilization.
// Logic: Corrects 'Cubic Residual' to maintain A+B+C+D=0.

module spu_nano_balancer #(
    parameter THRESHOLD = 32'd4 // Cubic Jitter Floor
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [31:0]  a_in, b_in, c_in, d_in,
    output reg  [31:0]  a_corr, b_corr, c_corr, d_corr,
    output wire         at_equilibrium
);

    // Stage 1: Calculate the Residual (The Gap in the Blanket)
    reg signed [31:0] residual;
    always @(posedge clk or posedge reset) begin
        if (reset) residual <= 32'd0;
        else residual <= $signed(a_in) + $signed(b_in) + $signed(c_in) + $signed(d_in);
    end

    // Stage 2: Laminar Thresholding & Distribution
    // If the residual is larger than the threshold, we distribute the correction.
    wire signed [31:0] corr_sip = residual >>> 2; // R/4 correction per axis
    wire is_active = (residual > $signed(THRESHOLD)) || (residual < -$signed(THRESHOLD));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            a_corr <= 32'd0; b_corr <= 32'd0; c_corr <= 32'd0; d_corr <= 32'd0;
        end else begin
            if (is_active) begin
                a_corr <= a_in - corr_sip;
                b_corr <= b_in - corr_sip;
                c_corr <= c_in - corr_sip;
                d_corr <= d_in - corr_sip;
            end else begin
                a_corr <= a_in;
                b_corr <= b_in;
                c_corr <= c_in;
                d_corr <= d_in;
            end
        end
    end

    assign at_equilibrium = !is_active;

endmodule
