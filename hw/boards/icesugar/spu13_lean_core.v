// SPU-13 LEAN CORE (v1.9 Circadian Parity)
// Target: Unified SPU-13 Fleet
// Objective: Full feature parity with Resonant Pulse + Purification.

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
    
    // Physical SPI Flash Pins
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
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

    // --- 3. Purification (Laminar Reset) ---
    wire flush_active;
    wire [15:0] seed_vector;
    wire flush_trigger; // Triggered via UART or Button
    spu_laminar_reset u_flush (
        .clk(`SPU_PIN_CLK), .trigger(flush_trigger),
        .flush_active(flush_active), .seed_vector(seed_vector),
        .sane_ack()
    );

    // --- 4. Bio-Resonance ---
    spu_bio_pulse #(.CLK_HZ(CLK_HZ)) u_bio (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .enable(1'b1), .intensity(8'h7F),
        .pulse_out(bio_pulse_out)
    );

    // --- 5. Soul Metabolism ---
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_soul_metabolism #(.CLK_HZ(CLK_HZ)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_state(reg_curr[127:0]),
        .fault_pulse(fault_detected),
        .is_idle(opcode == 3'b100),
        .adaptive_tau_q(), .tuck_count(), .cycle_count(),
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

    // --- 6. Instruction Sequencer ---
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
        end else if (flush_active) begin
            manifold_reg <= {240'b0, seed_vector}; // Flush with seed
        end else begin
            if (clk_resonant && step_cnt[15:0] == 16'hFFFF) begin
                step_cnt <= 0;
                if (opcode == 3'b100) pc <= 0; else pc <= pc + 1;
                manifold_reg <= reg_next;
            end else step_cnt <= step_cnt + 1;
        end
    end

    // --- 7. The Nano Core ---
    spu_nano_core u_core (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .reg_curr({128'b0, reg_curr[127:0]}),
        .opcode(opcode), .prime_phase(prime_phase), .sign_flip(sign_flip),
        .reg_out(reg_next[127:0]), .fault_detected(fault_detected)
    );

    // --- 8. Aura Mapping ---
    assign `SPU_PIN_LED_R = fault_detected;
    assign `SPU_PIN_LED_G = !fault_detected;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
