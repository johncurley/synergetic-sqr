// SPU-13 Isotropic Rasterizer (v2.9.21)
// Function: Deterministic Edge-Function Logic for Tetrahedral Synthesis.
// Logic: Bit-exact 64-bit integer coverage check for the IVM manifold.

module spu_rasterizer (
    input  wire         clk,
    input  wire         reset,
    input  wire [63:0]  v0_abcd, // Projected Vertex 0
    input  wire [63:0]  v1_abcd, // Projected Vertex 1
    input  wire [63:0]  v2_abcd, // Projected Vertex 2
    input  wire [31:0]  pixel_x,
    input  wire [31:0]  pixel_y,
    output wire         pixel_inside,
    output wire [7:0]   barycentric_weight
);

    // 1. Surd-Aware Edge Functions
    // Instead of floating-point cross products, we use 64-bit integer
    // determinants to calculate pixel coverage.
    
    wire signed [63:0] edge0 = (pixel_x - v0_abcd[31:0]) * (v1_abcd[63:32] - v0_abcd[63:32]) - 
                               (pixel_y - v0_abcd[63:32]) * (v1_abcd[31:0] - v0_abcd[31:0]);
                               
    wire signed [63:0] edge1 = (pixel_x - v1_abcd[31:0]) * (v2_abcd[63:32] - v1_abcd[63:32]) - 
                               (pixel_y - v1_abcd[63:32]) * (v2_abcd[31:0] - v1_abcd[31:0]);
                               
    wire signed [63:0] edge2 = (pixel_x - v2_abcd[31:0]) * (v0_abcd[63:32] - v2_abcd[63:32]) - 
                               (pixel_y - v2_abcd[63:32]) * (v0_abcd[31:0] - v2_abcd[31:0]);

    // 2. Coverage Logic (Topological Pass)
    assign pixel_inside = (edge0 >= 0 && edge1 >= 0 && edge2 >= 0);

    // 3. Barycentric Weight (Laminar Flow shading)
    // Used for the 'Purple Glow' intensity calculation in hardware.
    assign barycentric_weight = edge0[31:24] + edge1[31:24] + edge2[31:24];

endmodule
