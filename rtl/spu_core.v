// SPU-13 Integrated Core (v3.3.19 Phyllotaxis)
// Implements Fibonacci-Spiral Interconnects for Organic Data-Flow.
// Guard: Geometry Fluidizer integrated to purge Cubic Jitter.

module spu_core (
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] reg_curr,   
    input  wire [3071:0] neighbors, 
    input  wire [2:0]   opcode,     
    input  wire [1:0]   prime_phase,
    input  wire         sign_flip,  
    output reg  [831:0] reg_out,    
    output wire         fault_detected
);

    // 1. Internal Cleaning & ECC
    wire [831:0] cleaned_reg;
    wire [12:0]  lane_faults;
    assign fault_detected = |lane_faults;

    genvar i;
    generate
        for (i = 0; i < 13; i = i + 1) begin : ecc_lanes
            spu_ecc_decode decoder (
                .protected_word({7'b0, reg_curr[i*64 +: 32]}),
                .corrected_data(cleaned_reg[i*64 +: 32]),
                .double_error_detected(lane_faults[i])
            );
            assign cleaned_reg[i*64+32 +: 32] = reg_curr[i*64+32 +: 32];
        end
    endgenerate

    // 2. Geometry Fluidization
    // Quantizing coordinates to the IVM lattice nodes.
    wire [831:0] fluid_reg;
    generate
        for (i = 0; i < 26; i = i + 1) begin : fluidizer_lanes
            spu_geometry_fluidizer fluidizer (
                .brick_coord_in(cleaned_reg[i*32 +: 12]), // Quantizing lower 12 bits of each component
                .laminar_coord_out(fluid_reg[i*32 +: 12])
            );
            assign fluid_reg[i*32+12 +: 20] = cleaned_reg[i*32+12 +: 20];
        end
    endgenerate

    // 3. Phyllotaxis Interconnects (The SQR-Link)
    wire [63:0] f1  = fluid_reg[63:0];   // Lane 1
    wire [63:0] f2  = fluid_reg[127:64]; // Lane 2
    wire [63:0] f3  = fluid_reg[191:128];// Lane 3
    wire [63:0] f5  = fluid_reg[319:256];// Lane 5
    wire [63:0] f8  = fluid_reg[511:448];// Lane 8
    wire [63:0] f13 = fluid_reg[831:768];// Lane 13

    // 4. High-Dimensional Logic Units
    wire [255:0] sperm_x4_out;
    wire [831:0] sperm_13_out;
    wire [127:0] smul_13_out;

    spu_permute x4_unit (
        .clk(clk), .reset(reset), 
        .q_in(fluid_reg[255:0]), .prime_phase(prime_phase), 
        .sign_flip(sign_flip), .q_out(sperm_x4_out)
    );

    spu_permute_13 x13_unit (.q_in(fluid_reg), .q_out(sperm_13_out));

    // Integrated Phyllotaxis Multiplication
    spu_smul_13 phi_multiplier (
        .a1(f1[31:0]), .b1(f1[63:32]), .c1(f2[31:0]), .d1(f2[63:32]),
        .a2(f3[31:0]), .b2(f3[63:32]), .c2(f5[31:0]), .d2(f5[63:32]),
        .res_a(smul_13_out[31:0]), .res_b(smul_13_out[63:32]), 
        .res_c(smul_13_out[95:64]), .res_d(smul_13_out[127:96])
    );

    // 5. Register Dispatch (Organic Flow)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 832'b0;
        end else begin
            case (opcode)
                3'b001: reg_out <= {fluid_reg[831:256], sperm_x4_out};
                3'b110: reg_out <= sperm_13_out;
                3'b010: reg_out <= {fluid_reg[831:128], smul_13_out};
                default: reg_out <= fluid_reg;
            endcase
        end
    end

endmodule
