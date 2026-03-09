// SPU-13: The Sovereign Top-Level Wrapper (v4.0.0)
// Integrating the Adder, Rotor, and Quadrance
// Optimized for iCE40UP5K (iCeSugar)

module spu13_sovereign_top (
    input  wire clk,         // 12MHz Lattice Pulse
    input  wire reset,       // The Reset Invariant
    input  wire [11:0] lean, // Skateboard Input (Spread Index)
    output wire [47:0] depth // Quadrance Output (The "View")
);

    // Internal Quadray Registers (ABCD)
    reg [23:0] cur_a, cur_b, cur_c, cur_d;
    wire [23:0] next_a, next_b, next_c, next_d;

    // 1. The Spread Rotor: Turning "Lean" into Rotation
    spread_rotor rotor_inst (
        .spread_idx(lean),
        .vec_in_A(cur_a), .vec_in_B(cur_b), .vec_in_C(cur_c), .vec_in_D(cur_d),
        .vec_out_A(next_a), .vec_out_B(next_b), .vec_out_C(next_c), .vec_out_D(next_d)
    );

    // 2. State Accumulator & Normalizer: Exorcising the Error
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize to unit vector on Axis A
            // D must be -A to satisfy the invariant
            cur_a <= 24'h010000; 
            cur_b <= 24'h0;
            cur_c <= 24'h0;
            cur_d <= -24'h010000; 
        end else begin
            cur_a <= next_a; 
            cur_b <= next_b;
            cur_c <= next_c; 
            
            // The Normalizer: Force-balancing the tetrahedral center
            // D = -(A + B + C) ensures sum is always zero.
            cur_d <= -(next_a + next_b + next_c);
        end
    end

    // 3. The Quadrance Calc: Seeing the "Depth" of the Flow
    quadrance_calc depth_engine (
        .a(cur_a), .b(cur_b), .c(cur_c), .d(cur_d),
        .q_out(depth)
    );

endmodule
