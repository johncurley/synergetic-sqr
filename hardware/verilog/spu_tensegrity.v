// SPU-1 Tensegrity Accelerator
// Implements bit-locked Verlet Integration: x_next = 2x - x_prev + a * dt_sq
// dt_sq is assumed to be 1 for single-tick hardware dispatch.

module spu_tensegrity (
    input  [255:0] curr_pos,
    input  [255:0] prev_pos,
    input  [255:0] accel,
    output [255:0] next_pos
);

    // Verlet logic per lane (8 sub-components total)
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : verlet_lanes
            wire signed [31:0] x      = curr_pos[i*32 +: 32];
            wire signed [31:0] x_prev = prev_pos[i*32 +: 32];
            wire signed [31:0] a      = accel[i*32 +: 32];

            // x_next = (x << 1) - x_prev + a
            assign next_pos[i*32 +: 32] = (x << 1) - x_prev + a;
        end
    endgenerate

endmodule
