// SPU-1 Top-Level Hardware Core (v2.0.24)
// Implements the True Laplacian Update: x_new = x_curr + alpha * Sum(u_j - u_i)

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,  // Current Node State (xi)
    input  wire [3071:0] neighbors, // Carry relational displacements (uj - xi)
    input  wire [1:0]   opcode,    // 00: NOP, 01: SPERM, 10: SMUL, 11: OP_EQUILIBRATE
    output reg  [255:0] reg_out
);

    // Opcodes
    localparam OP_NOP         = 2'b00;
    localparam OP_SPERM       = 2'b01;
    localparam OP_SMUL        = 2'b10;
    localparam OP_EQUILIBRATE = 2'b11;

    // Internal Wires
    wire [255:0] permute_out;
    wire [255:0] scaled_residual;
    wire [255:0] equilibrate_sum;
    wire [31:0]  smul_a_out, smul_b_out;

    // 1. Permutator (Zero-Gate)
    spu_permute permutator (
        .q_in(reg_curr),
        .q_out(permute_out)
    );

    // 2. Tensegrity Balancer (Combinational Laplacian Residual)
    spu_tensegrity_balancer balancer (
        .neighbors(neighbors),
        .scaled_residual(scaled_residual)
    );

    // 3. True Laplacian Final Addition: xi + scaled_residual
    spu_sadd laplacian_adder (
        .u(reg_curr),
        .v(scaled_residual),
        .sum(equilibrate_sum)
    );

    // 4. Multiplier (Lane 1 Demo)
    spu_smul multiplier (
        .a1(reg_curr[31:0]),  .b1(reg_curr[63:32]),
        .a2(32'd65536),       .b2(32'd0), // Identity Proxy
        .a_out(smul_a_out),   .b_out(smul_b_out)
    );

    // 5. Sequential Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                OP_SPERM:       reg_out <= permute_out;
                OP_EQUILIBRATE: reg_out <= equilibrate_sum;
                OP_SMUL:        reg_out <= {reg_curr[255:64], smul_b_out, smul_a_out};
                default:        reg_out <= reg_curr;
            endcase
        end
    end

endmodule
