// SPU-1 Top-Level Hardware Core (v2.0.26)
// Implements Pipelined Laplacian Update and Double-Buffered State Snapshots

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,   // Current Node State (From Bank A)
    input  wire [3071:0] neighbors, // Snapshot of 12-neighbor shell
    input  wire [1:0]   opcode,     // 00: NOP, 01: SPERM, 10: SMUL, 11: OP_EQUILIBRATE
    output reg  [255:0] reg_out     // Final Commit State (To Bank B)
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

    // 1. Permutator (Combinational)
    spu_permute permutator (
        .q_in(reg_curr),
        .q_out(permute_out)
    );

    // 2. Pipelined Balancer (3-Cycle Latency)
    spu_tensegrity_balancer balancer (
        .clk(clk),
        .reset(reset),
        .neighbors(neighbors),
        .scaled_residual(scaled_residual)
    );

    // 3. Laplacian Addition: xi + residual
    spu_sadd laplacian_adder (
        .u(reg_curr),
        .v(scaled_residual),
        .sum(equilibrate_sum)
    );

    // 4. Multiplier (Lane 1 Demo)
    spu_smul multiplier (
        .a1(reg_curr[31:0]),  .b1(reg_curr[63:32]),
        .a2(32'd65536),       .b2(32'd0), 
        .a_out(smul_a_out),   .b_out(smul_b_out)
    );

    // 5. Sequential Dispatch (Atomic Commit)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                OP_SPERM:       reg_out <= permute_out;
                OP_EQUILIBRATE: reg_out <= equilibrate_sum; // Note: Reflects residual from 3 cycles ago
                OP_SMUL:        reg_out <= {reg_curr[255:64], smul_b_out, smul_a_out};
                default:        reg_out <= reg_curr;
            endcase
        end
    end

endmodule
