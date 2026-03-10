// SPU-13 NANO CORE (v1.5 Pipelined Davis Edition)
// Target: iCE40UP5K (iCeSugar Nano)
// Objective: Restore 12MHz+ timing while maintaining the Davis Gasket.
// Feature: Single-cycle Pipelined Recovery.

module spu_nano_core #(
    parameter [63:0] TAU_Q = 64'h00000000_00010000 // tau^2
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [127:0] reg_curr,   
    input  wire [2:0]   opcode,     
    input  wire [1:0]   prime_phase,
    input  wire         sign_flip,  
    output reg  [127:0] reg_out,    
    output reg          fault_detected
);

    // --- 1. Internal Units ---
    wire signed [31:0] A_in = reg_curr[31:0];
    wire signed [31:0] B_in = reg_curr[63:32];
    wire signed [31:0] C_in = reg_curr[95:64];
    wire signed [31:0] D_in = reg_curr[127:96];

    // Unit A: Nano-Rotor
    wire signed [31:0] rot_A = B_in;
    wire signed [31:0] rot_B = C_in;
    wire signed [31:0] rot_C = D_in;
    wire signed [31:0] rot_D = A_in;

    // Unit B: Quad Adder
    wire signed [31:0] add_A = A_in + A_in;
    wire signed [31:0] add_B = B_in + B_in;
    wire signed [31:0] add_C = C_in + C_in;
    wire signed [31:0] add_D = D_in + D_in;

    // Unit C: Active Annealer (ANNE)
    wire signed [31:0] anne_A = A_in - (A_in >>> 4);
    wire signed [31:0] anne_B = B_in - (B_in >>> 4);
    wire signed [31:0] anne_C = C_in - (C_in >>> 4);
    wire signed [31:0] anne_D = D_in - (D_in >>> 4);

    // --- 2. Combinatorial Proposal ---
    reg signed [31:0] p_A, p_B, p_C, p_D;
    always @(*) begin
        case (opcode)
            3'b000: begin p_A = add_A; p_B = add_B; p_C = add_C; p_D = add_D; end
            3'b001: begin p_A = rot_A; p_B = rot_B; p_C = rot_C; p_D = rot_D; end
            3'b111: begin p_A = anne_A; p_B = anne_B; p_C = anne_C; p_D = anne_D; end
            default: begin p_A = A_in; p_B = B_in; p_C = C_in; p_D = D_in; end
        endcase
    end

    // --- 3. The Pipelined Gasket ---
    wire over_curvature;
    spu_davis_gate #(
        .TAU_Q(TAU_Q)
    ) u_gate (
        .a(p_A[31:16]), .b(p_B[31:16]), .c(p_C[31:16]), .d(p_D[31:16]),
        .over_curvature(over_curvature)
    );

    wire signed [31:0] residual = p_A + p_B + p_C + p_D;
    wire is_leaking = (residual != 32'd0);
    wire signed [31:0] correction = residual >>> 2;

    // Register the output to break the timing chain
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 128'b0;
            fault_detected <= 1'b0;
        end else begin
            fault_detected <= is_leaking | over_curvature;
            // Apply correction before registering
            reg_out <= {p_D - correction, p_C - correction, p_B - correction, p_A - correction};
        end
    end

endmodule
