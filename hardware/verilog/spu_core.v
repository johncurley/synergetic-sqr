// SPU-1 Integrated Core (v2.0.33)
// Includes Pipelined Laplacian, ECC, and Prime-Axis Permutation control

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,   // Input from Bank A
    input  wire [3071:0] neighbors, // Relational bus
    input  wire [1:0]   opcode,     // 00: NOP, 01: SPERM, 10: SMUL, 11: OP_EQUILIBRATE
    input  wire [1:0]   prime_phase,// Selection for SPERM: P1, P3, P5, P7
    output reg  [255:0] reg_out,    // Protected output to Bank B
    output wire         fault_detected
);

    wire [255:0] cleaned_reg;
    wire [7:0]   lane_faults;
    assign fault_detected = |lane_faults;

    // 1. ECC Decoder
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : ecc_in
            spu_ecc_decode decoder (
                .protected_word({7'b0, reg_curr[i*32 +: 32]}),
                .corrected_data(cleaned_reg[i*32 +: 32]),
                .double_error_detected(lane_faults[i])
            );
        end
    endgenerate

    // 2. Logic Units
    wire [255:0] permute_out;
    wire [255:0] scaled_residual;
    wire [255:0] equilibrate_sum;
    wire [31:0]  smul_a_out, smul_b_out;

    // Parameterized Prime-Axis Permutator
    spu_permute permutator (
        .q_in(cleaned_reg), 
        .prime_phase(prime_phase), 
        .q_out(permute_out)
    );

    spu_tensegrity_balancer balancer (.clk(clk), .reset(reset), .neighbors(neighbors), .scaled_residual(scaled_residual));
    spu_sadd laplacian_adder (.u(cleaned_reg), .v(scaled_residual), .sum(equilibrate_sum));
    spu_smul multiplier (.a1(cleaned_reg[31:0]), .b1(cleaned_reg[63:32]), .a2(32'd65536), .b2(32'd0), .a_out(smul_a_out), .b_out(smul_b_out));

    // 3. Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                2'b01: reg_out <= permute_out;
                2'b11: reg_out <= equilibrate_sum;
                2'b10: reg_out <= {cleaned_reg[255:64], smul_b_out, smul_a_out};
                default: reg_out <= cleaned_reg;
            endcase
        end
    end

endmodule
