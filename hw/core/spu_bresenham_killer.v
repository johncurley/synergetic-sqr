// SPU-13 Bresenham-Killer: Rational Lattice Traversal (v1.0)
// Objective: Smooth, jitter-free line drawing through the Quadray Manifold.
// Logic: Incremental rational steps phase-locked to the 61.44 kHz heartbeat.

module spu_bresenham_killer (
    input  wire        clk,
    input  wire        reset,
    input  wire        pulse_61k,
    input  wire        start,
    
    // Line Definition (Start/End Quadrays)
    input  wire [15:0] q_a_start, q_b_start, q_c_start, q_d_start,
    input  wire [15:0] q_a_end,   q_b_end,   q_c_end,   q_d_end,
    
    // Current Manifold Position (Streaming Output)
    output reg  [15:0] out_a, out_b, out_c, out_d,
    output reg         busy,
    output reg         done
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_a <= 0; out_b <= 0; out_c <= 0; out_d <= 0;
            busy  <= 0; done  <= 0;
        end else if (start && !busy) begin
            out_a <= q_a_start; out_b <= q_b_start;
            out_c <= q_c_start; out_d <= q_d_start;
            busy  <= 1; done  <= 0;
        end else if (busy && pulse_61k) begin
            // Incremental Rational Step: Move 1 unit toward the end on each axis
            if (out_a != q_a_end) out_a <= out_a + (q_a_end > out_a ? 1 : -1);
            if (out_b != q_b_end) out_b <= out_b + (q_b_end > out_b ? 1 : -1);
            if (out_c != q_c_end) out_c <= out_c + (q_c_end > out_c ? 1 : -1);
            if (out_d != q_d_end) out_d <= out_d + (q_d_end > out_d ? 1 : -1);
            
            // Completion Check
            if (out_a == q_a_end && out_b == q_b_end && 
                out_c == q_c_end && out_d == q_d_end) begin
                busy <= 0; done <= 1;
            end
        end
    end

endmodule
