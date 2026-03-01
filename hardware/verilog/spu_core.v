// SPU-1 Top-Level Hardware Core
// Integrates SMUL and SPERM into a single Quadray pipeline stage

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_in,
    input  wire [1:0]   opcode, // 00: NOP, 01: SPERM, 10: SMUL (self)
    output reg  [255:0] reg_out
);

    // Opcodes
    localparam OP_NOP   = 2'b00;
    localparam OP_SPERM = 2'b01;
    localparam OP_SMUL  = 2'b10;

    // Internal Wires for Module Connections
    wire [255:0] permute_out;
    wire [31:0]  smul_a_out, smul_b_out;

    // 1. Permutator (Zero-Gate Logic)
    spu_permute permutator (
        .q_in(reg_in),
        .q_out(permute_out)
    );

    // 2. Surd Multiplier (Lane 1 only for demo)
    spu_smul multiplier (
        .a1(reg_in[31:0]),  .b1(reg_in[63:32]),
        .a2(65536),         .b2(0), // Multiply by identity proxy
        .a_out(smul_a_out), .b_out(smul_b_out)
    );

    // 3. Sequential Register Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                OP_SPERM: reg_out <= permute_out;
                OP_SMUL:  reg_out <= {reg_in[255:64], smul_b_out, smul_a_out};
                default:  reg_out <= reg_in;
            endcase
        end
    end

endmodule
