// SPU-13 LEAN CORE (v1.8 Soul Integrated)
// Target: Unified SPU-13 Fleet
// Objective: Streamlined engine with Resonant Heart + Soul Metabolism.

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
    
    // Physical SPI Flash Pins (The Soul)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso
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

    // --- 3. Soul Metabolism (The Personality) ---
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_soul_metabolism #(.CLK_HZ(CLK_HZ)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_state(reg_curr[127:0]),
        .fault_pulse(fault_detected),
        .is_idle(opcode == 3'b100), // LEAP/Idle trigger
        .tuck_count(), .cycle_count(),
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

    // --- 4. Instruction Sequencer (The Bloom) ---
    reg [7:0] instruction_rom [0:15];
    reg [3:0] pc;
    reg [23:0] step_cnt; 
    initial $readmemh("../../software/bloom.hex", instruction_rom);

    wire [7:0] current_instr = instruction_rom[pc];
    assign opcode = current_instr[7:5];
    assign prime_phase = current_instr[4:3];
    assign sign_flip = current_instr[2];

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

    // --- 5. The Nano Core (ALU) ---
    spu_nano_core u_core (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .reg_curr({128'b0, reg_curr[127:0]}),
        .opcode(opcode), .prime_phase(prime_phase), .sign_flip(sign_flip),
        .reg_out(reg_next[127:0]), .fault_detected(fault_detected)
    );
    assign reg_next[255:128] = 128'b0;

    // --- 6. Aura Mapping ---
    assign `SPU_PIN_LED_R = fault_detected;
    assign `SPU_PIN_LED_G = !fault_detected;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
