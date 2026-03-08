// SPU-13 Integrated Core (v3.3.25 Phyllotaxis)
// Implements Fibonacci-Spiral Interconnects for Organic Data-Flow.
// Guard: Geometry Fluidizer integrated to purge Cubic Jitter.
// Bridge: Rational Trigonometry integrated for bit-exact Quadrance Audits.
// Flow: Fluid Solver and Isotropic Annealer integrated into the Dispatch.

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
    // NOTE: These lanes are currently transparent (Laminar Integrity). 
    // Bit-flip protection is mapped to Geometric Redundancy in Phase 2.
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
                .brick_coord_in(cleaned_reg[i*32 +: 12]), 
                .laminar_coord_out(fluid_reg[i*32 +: 12])
            );
            assign fluid_reg[i*32+12 +: 20] = cleaned_reg[i*32+12 +: 20];
        end
    endgenerate

    // 3. High-Dimensional Logic Units
    wire [255:0] sperm_x4_out;
    wire [831:0] sperm_13_out;
    wire [127:0] smul_13_out;
    wire [63:0]  quadrance_out;
    wire [831:0] fluid_out;
    wire [831:0] annealed_out;
    wire [255:0] bypass_out;

    // Sierpiński Quadrance Bypass (Phase-Isolated Tunnels)
    spu_fractal_bypass u_bypass (
        .q_in(fluid_reg[255:0]),
        .phase(prime_phase),
        .q_out(bypass_out)
    );

    spu_permute x4_unit (
        .clk(clk), .reset(reset), 
        .q_in(bypass_out), .prime_phase(prime_phase), 
        .sign_flip(sign_flip), .q_out(sperm_x4_out)
    );

    spu_permute_13 x13_unit (.q_in(fluid_reg), .q_out(sperm_13_out));

    spu_smul_13 phi_multiplier (
        .a1(fluid_reg[31:0]),   .b1(fluid_reg[63:32]), 
        .c1(fluid_reg[95:64]),  .d1(fluid_reg[127:96]),
        .a2(fluid_reg[159:128]), .b2(fluid_reg[191:160]), 
        .c2(fluid_reg[223:192]), .d2(fluid_reg[255:224]),
        .res_a(smul_13_out[31:0]), .res_b(smul_13_out[63:32]), 
        .res_c(smul_13_out[95:64]), .res_d(smul_13_out[127:96])
    );

    // Rational Trigonometry: Quadrance of the first Quadray vector
    // Guarded by the Symmetry Guard (Lego-to-Laminar)
    spu_rational_trig trig_unit (
        .a(fluid_reg[31:0]), .b(fluid_reg[63:32]), 
        .c(fluid_reg[95:64]), .d(fluid_reg[127:96]),
        .quadrance(quadrance_out),
        .spread_60_fixed(),
        .a_cubic_laminar(),
        .b_cubic_laminar(),
        .c_cubic_laminar(),
        .d_cubic_laminar()
    );

    // 4. G-RAM: Geometric Memory (Standing Wave Buffer)
    wire [831:0] gram_data_out;
    spu_gram_controller u_gram (
        .clk(clk), .reset(reset),
        .janus_bit(sign_flip),
        .addr_in(fluid_reg[31:0]),
        .data_in(fluid_reg),
        .write_en(opcode == 3'b100), // Opcode 100: G-RAM Write
        .data_out(gram_data_out),
        .ready()
    );

    // 5. Deterministic Fluid Solver (Navier-Stokes Closure)
    spu_fluid_solver u_solver (
        .clk(clk), .reset(reset),
        .velocity_in(fluid_reg),
        .neighbors(neighbors),
        .velocity_out(fluid_out),
        .laminar_lock()
    );

    // 6. Isotropic Annealer (Golden Noise)
    spu_annealer u_annealer (
        .clk(clk), .reset(reset),
        .enable(opcode == 3'b111), // Opcode 111: Perturb
        .reg_in(fluid_reg),
        .reg_out(annealed_out)
    );

    // 7. Harmonic Visualization Engine (Auditory Fractal Bridge)
    wire [31:0] harmonic_color;
    wire [63:0] harmonic_vector;
    spu_harmonic_vis u_vis (
        .clk(clk), .reset(reset),
        .freq_in(fluid_reg[15:0]),
        .amplitude(fluid_reg[23:16]),
        .color_out(harmonic_color),
        .vector_out(harmonic_vector)
    );

    // 8. Identity Gate: The Rational Guard
    wire identity_lock;
    wire [63:0] h_seed;
    spu_identity_monad u_identity (
        .clk(clk),
        .current_quadrance(quadrance_out),
        .lattice_state(fluid_reg),
        .identity_aligned(identity_lock),
        .homeopathic_seed(h_seed)
    );

    // 9. Register Dispatch (ISA Expansion)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_out <= 832'b0;
        end else begin
            case (opcode)
                3'b001: reg_out <= {fluid_reg[831:256], sperm_x4_out}; // SPERM_X4
                3'b010: reg_out <= {fluid_reg[831:128], smul_13_out}; // SMUL_13
                3'b011: reg_out <= {fluid_reg[831:64],  quadrance_out}; // Q_AUDIT
                3'b100: reg_out <= gram_data_out;                     // G_RAM
                3'b101: reg_out <= fluid_out;                         // FLUID_SOLVE
                3'b110: reg_out <= sperm_13_out;                      // SPERM_13
                3'b111: reg_out <= annealed_out;                    // PERTURB
                default: reg_out <= fluid_reg;                        // NOP / PASS
            endcase
        end
    end

    assign fault_detected = (|lane_faults) | (!identity_lock);

endmodule
