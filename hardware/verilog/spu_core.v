// SPU-1 Integrated Core (v2.1.1)
// Integrates SMUL, SPERM_X4, EQUILIBRATE, and OP_DAMP

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [255:0] reg_curr,
    input  wire [3071:0] neighbors,
    input  wire [2:0]   opcode,      // Expanded to 3 bits
    input  wire [1:0]   prime_phase,
    output reg  [255:0] reg_out,
    output wire         fault_detected,
    output wire [1:0]   current_prime_phase,
    output wire         at_inertial_rest // New Status bit
);

    wire [255:0] cleaned_reg;
    wire [7:0]   lane_faults;
    assign fault_detected = |lane_faults;
    assign current_prime_phase = prime_phase;
    assign at_inertial_rest = (cleaned_reg == 256'b0);

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
    wire [255:0] damp_out;
    wire [31:0]  smul_a_out, smul_b_out;

    spu_permute permutator (.q_in(cleaned_reg), .prime_phase(prime_phase), .q_out(permute_out));
    spu_tensegrity_balancer balancer (.clk(clk), .reset(reset), .neighbors(neighbors), .scaled_residual(scaled_residual));
    spu_sadd laplacian_adder (.u(cleaned_reg), .v(scaled_residual), .sum(equilibrate_sum));
    spu_damper damper (.q_in(cleaned_reg), .q_out(damp_out));
    spu_smul multiplier (.a1(cleaned_reg[31:0]), .b1(cleaned_reg[63:32]), .a2(32'd65536), .b2(32'd0), .a_out(smul_a_out), .b_out(smul_b_out));

    // 3. Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 256'b0;
        end else begin
            case (opcode)
                3'b001: reg_out <= permute_out;     // SPERM_X4
                3'b011: reg_out <= equilibrate_sum; // EQUILIBRATE
                3'b100: reg_out <= damp_out;        // OP_DAMP
                3'b010: reg_out <= {cleaned_reg[255:64], smul_b_out, smul_a_out}; // SMUL
                default: reg_out <= cleaned_reg;
            endcase
        end
    end

endmodule
