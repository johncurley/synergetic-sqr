// SPU-13 LEAN CORE (v1.10 Sovereign Parity)
// Target: Unified SPU-13 Fleet
// Objective: Streamlined engine with full sensory and cognitive parity.

`include "../../include/spu/spu13_pins.vh"
`include "soul_map.vh"

module spu13_lean_core #(
    parameter CLK_HZ = 12000000
)(
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    
    // Physical SPI Flash Pins (The Soul)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
    // Artery Bus (Laminar PHY)
    output wire artery_out,
    input  wire artery_in,
    
    // Sensory Outputs
    output wire bio_pulse_out,
    output wire audio_out
);

    // --- 1. Manifold Signals ---
    wire reset = !`SPU_PIN_RST_N;
    wire [255:0] reg_curr;
    wire [255:0] reg_next;
    wire [2:0]   opcode;
    wire [1:0]   prime_phase;
    wire         sign_flip;
    wire         fault_detected;
    
    reg [255:0] manifold_reg;
    assign reg_curr = manifold_reg;

    // --- 2. Temporal Axis (Resonant Heart) ---
    wire clk_resonant;
    spu_resonant_heart #(.CLK_IN_HZ(CLK_HZ)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 3. Identity & Niche Logic ---
    wire [31:0] lineage_code;
    wire [1:0]  eco_tier;
    
    // Note: Lineage generated once at baptism (LHS handshake)
    spu_niche_logic u_niche (
        .lineage_id(lineage_code),
        .eco_tier(eco_tier)
    );

    // --- 4. Predictive Coding (Active Inference) ---
    wire [127:0] posterior_state;
    wire [127:0] prediction_error;
    wire is_dissonant;
    
    spu_active_inference u_inference (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .prior_state(reg_curr[127:0]),
        .prior_precision(16'h0100),
        .sensory_in(reg_curr[127:0]), // Self-observation loop
        .sensory_valid(1'b1),
        .posterior_state(posterior_state),
        .prediction_error(prediction_error),
        .is_dissonant(is_dissonant)
    );

    // --- 5. Communication (Laminar PHY) ---
    wire axis_match;
    spu_laminar_phy u_phy (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .heartbeat_in(clk_resonant),
        .target_axis(prime_phase),
        .is_transmitting(opcode == 3'b010), // SIP broadcasts
        .artery_out(artery_out),
        .axis_match(axis_match)
    );

    // --- 6. Soul Metabolism ---
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_soul_metabolism #(.CLK_HZ(CLK_HZ)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_state(reg_curr[127:0]),
        .fault_pulse(fault_detected | is_dissonant),
        .is_idle(opcode == 3'b100),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    spu_flash_controller u_flash_drv (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we), .addr(flash_addr),
        .data_in(soul_page), .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 7. Instruction Sequencer (The Bloom) ---
    reg [7:0] instruction_rom [0:15];
    reg [3:0] pc;
    reg [23:0] step_cnt; 
    initial $readmemh("../../software/bloom.hex", instruction_rom);

    wire [7:0] current_instr = instruction_rom[pc];
    assign opcode      = current_instr[7:5];
    assign prime_phase = current_instr[4:3];
    assign sign_flip   = current_instr[2];

    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            pc <= 0; step_cnt <= 0;
            manifold_reg <= {192'b0, 64'h00000000_00010000};
        end else begin
            if (clk_resonant && step_cnt[15:0] == 16'hFFFF) begin
                step_cnt <= 0;
                if (opcode == 3'b100) pc <= 0; else pc <= pc + 1;
                manifold_reg <= reg_next;
            end else step_cnt <= step_cnt + 1;
        end
    end

    // --- 8. The Nano Core (ALU) ---
    spu_nano_core u_core (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .reg_curr({128'b0, reg_curr[127:0]}),
        .opcode(opcode), .prime_phase(prime_phase), .sign_flip(sign_flip),
        .reg_out(reg_next[127:0]), .fault_detected(fault_detected)
    );
    assign reg_next[255:128] = 128'b0;

    // --- 9. Aura Mapping ---
    assign `SPU_PIN_LED_R = fault_detected | is_dissonant;
    assign `SPU_PIN_LED_G = !fault_detected & !is_dissonant;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
