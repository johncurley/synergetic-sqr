// SPU-1 Top-Level Hardware Core (v1.11.3)
// Integrates SMUL, SPERM, and SP_VERLET into a single pipeline stage

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,  // Current Position / Operand 1
    input  wire [255:0] reg_prev,  // Previous Position / Operand 2
    input  wire [255:0] reg_accel, // Acceleration / Constant
    input  wire [1:0]   opcode,    // 00: NOP, 01: SPERM, 10: SMUL, 11: OP_VERLET
    output reg  [255:0] reg_out
);

    // Opcodes
    localparam OP_NOP    = 2'b00;
    localparam OP_SPERM  = 2'b01;
    localparam OP_SMUL   = 2'b10;
    localparam OP_VERLET = 2'b11;

    // Internal Wires
    wire [255:0] permute_out;
    wire [255:0] verlet_out;
    wire [31:0]  smul_a_out, smul_b_out;

    // 1. Permutator (Zero-Gate)
    spu_permute permutator (
        .q_in(reg_curr),
        .q_out(permute_out)
    );

    // 2. Tensegrity Accelerator
    spu_tensegrity kinetic_unit (
        .curr_pos(reg_curr),
        .prev_pos(reg_prev),
        .accel(reg_accel),
        .next_pos(verlet_out)
    );

    // 3. Multiplier (Lane 1 Demo)
    spu_smul multiplier (
        .a1(reg_curr[31:0]),  .b1(reg_curr[63:32]),
        .a2(reg_prev[31:0]),  .b2(reg_prev[63:32]),
        .a_out(smul_a_out),   .b_out(smul_b_out)
    );

    // 4. Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                OP_SPERM:  reg_out <= permute_out;
                OP_VERLET: reg_out <= verlet_out;
                OP_SMUL:   reg_out <= {reg_curr[255:64], smul_b_out, smul_a_out};
                default:   reg_out <= reg_curr;
            endcase
        end
    end

endmodule
