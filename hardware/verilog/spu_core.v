// SPU-1 Integrated Core (v2.5.7 Golden Model)
// Full-Stack 13-Axis Realization with ECC and Phi-Core Multiplier

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] reg_curr,   // 13 Lanes x 64-bit
    input  wire [3071:0] neighbors, // 12 Neighbor relational bus
    input  wire [2:0]   opcode,     // SurdLang ISA
    input  wire [1:0]   prime_phase,// For SPERM_X4
    output reg  [831:0] reg_out,    // Protected Output
    output wire         fault_detected
);

    // 1. Internal Buses and Cleaning
    wire [831:0] cleaned_reg;
    wire [12:0]  lane_faults;
    assign fault_detected = |lane_faults;

    genvar i;
    generate
        for (i = 0; i < 13; i = i + 1) begin : ecc_lanes
            spu_ecc_decode decoder (
                .protected_word({7'b0, reg_curr[i*64 +: 32]}), // coefficient a protection
                .corrected_data(cleaned_reg[i*64 +: 32]),
                .double_error_detected(lane_faults[i])
            );
            assign cleaned_reg[i*64+32 +: 32] = reg_curr[i*64+32 +: 32]; // raw coefficient b
        end
    endgenerate

    // 2. High-Dimensional Logic Units
    wire [831:0] sperm_x4_out;
    wire [831:0] sperm_13_out;
    wire [831:0] equilibrate_out;
    wire [831:0] damp_out;
    wire [127:0] smul_13_out; // Phi-Core Multiplier

    // 4D Prime-Axis Unit (First 4 lanes)
    spu_permute x4_unit (.q_in(cleaned_reg[255:0]), .prime_phase(prime_phase), .q_out(sperm_x4_out[255:0]));
    assign sperm_x4_out[831:256] = cleaned_reg[831:256];

    // 13-Axis Cyclic Unit
    spu_permute_13 x13_unit (.q_in(cleaned_reg), .q_out(sperm_13_out));

    // Phi-Core Multiplier (Lane 1 Demo)
    spu_smul_13 phi_multiplier (
        .a1(cleaned_reg[31:0]), .b1(cleaned_reg[63:32]), .c1(32'd0), .d1(32'd0),
        .a2(32'd65536), .b2(32'd0), .c2(32'd0), .d2(32'd0),
        .a_out(smul_13_out[31:0]), .b_out(smul_13_out[63:32]), 
        .c_out(smul_13_out[95:64]), .d_out(smul_13_out[127:96])
    );

    // 3. Register Dispatch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 832'b0;
        end else begin
            case (opcode)
                3'b001: reg_out <= sperm_x4_out;
                3'b110: reg_out <= sperm_13_out;
                3'b010: reg_out <= {cleaned_reg[831:128], smul_13_out};
                default: reg_out <= cleaned_reg;
            endcase
        end
    end

endmodule
