// SPU-13 LEAN CORE (v1.7 Sovereign Parity)
// Target: Unified SPU-13 Fleet
// Objective: Streamlined spatial engine with Resonant Heart + SANE Whisper.

`include "../../include/spu/spu13_pins.vh"

module spu13_lean_core #(
    parameter CLK_HZ = 12000000
)(
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    // Status Display (RGB LED)
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // OLED Interface
    output wire oled_scl,
    output wire oled_sda,
    
    // Interaction
    output wire `SPU_PIN_UART_TX
);

    // --- 1. Manifold Signals ---
    wire reset = !`SPU_PIN_RST_N;
    wire [255:0] reg_curr;
    wire [255:0] reg_next;
    wire [2:0]   opcode;
    wire [1:0]   prime_phase;
    wire         sign_flip;
    
    // Main Manifold Register
    reg [255:0] manifold_reg;
    assign reg_curr = manifold_reg;

    // --- 2. Temporal Axis (The Resonant Heart) ---
    wire clk_resonant;
    spu_resonant_heart #(.CLK_IN_HZ(CLK_HZ)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 3. Voice of Coherency (SANE Pulse) ---
    wire fault_detected;
    spu_whisper_sane #(.CLK_HZ(CLK_HZ), .BAUD(115200)) u_sane_voice (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!fault_detected),
        .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 4. Instruction Sequencer (The Bloom) ---
    reg [7:0] instruction_rom [0:15];
    reg [3:0] pc;
    reg [23:0] step_cnt; 
    
    initial begin
        $readmemh("../../software/bloom.hex", instruction_rom);
    end

    wire [7:0] current_instr = instruction_rom[pc];
    assign opcode      = current_instr[7:5];
    assign prime_phase = current_instr[4:3];
    assign sign_flip   = current_instr[2];

    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            pc <= 0; step_cnt <= 0;
            manifold_reg <= {192'b0, 64'h00000000_00010000};
        end else begin
            // Evolution synchronized to the Resonant Heart (approx 1 pulse per logic step)
            if (clk_resonant && step_cnt[15:0] == 16'hFFFF) begin
                step_cnt <= 0;
                if (opcode == 3'b100) pc <= 0; 
                else pc <= pc + 1;
                manifold_reg <= reg_next;
            end else begin
                step_cnt <= step_cnt + 1;
            end
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

    // --- 6. OLED Visualizer ---
    spu_ssd1306_driver u_oled (
        .clk(clk_resonant), // Uses the same Sovereign clock
        .reset(reset),
        .data_in(reg_curr[7:0]), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    // --- 7. Aura Mapping ---
    assign `SPU_PIN_LED_R = reset | fault_detected;
    assign `SPU_PIN_LED_G = !reset & !fault_detected;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
