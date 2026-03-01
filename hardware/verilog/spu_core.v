// SPU-1 Top-Level Hardware Core (v2.0)
// Integrates SMUL, SPERM, and OP_EQUILIBRATE into a single pipeline stage

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,  // Current Node State
    input  wire [3071:0] neighbors, // 12 Neighbor Registers
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
    wire [255:0] balance_out;
    wire [31:0]  smul_a_out, smul_b_out;

    // 1. Permutator (Zero-Gate)
    spu_permute permutator (
        .q_in(reg_curr),
        .q_out(permute_out)
    );

    // 2. Tensegrity Balancer (Equilibrium Unit)
    spu_tensegrity_balancer balancer (
        .clk(clk),
        .reset(reset),
        .neighbors(neighbors),
        .correction_vector(balance_out)
    );

    // 3. Multiplier (Lane 1 Demo)
    spu_smul multiplier (
        .a1(reg_curr[31:0]),  .b1(reg_curr[63:32]),
        .a2(32'd65536),       .b2(32'd0), // Identity Proxy
        .a_out(smul_a_out),   .b_out(smul_b_out)
    );

    // 4. Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                OP_SPERM:       reg_out <= permute_out;
                OP_EQUILIBRATE: reg_out <= balance_out;
                OP_SMUL:        reg_out <= {reg_curr[255:64], smul_b_out, smul_a_out};
                default:        reg_out <= reg_curr;
            endcase
        end
    end

endmodule
