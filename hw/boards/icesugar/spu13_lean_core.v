// SPU-13 LEAN CORE (v1.6 OLED Visualizer)
// Target: Unified SPU-13 Fleet
// Objective: Streamlined spatial engine with Instruction Sequencer + OLED.

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
    
    // OLED Interface (HAL pins mapped in PCF)
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
    wire         identity_aligned;
    
    // Main Manifold Register
    reg [255:0] manifold_reg;
    assign reg_curr = manifold_reg;

    // --- 2. Instruction Sequencer (The Bloom) ---
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
            pc <= 0;
            step_cnt <= 0;
            manifold_reg <= {192'b0, 64'h00000000_00010000};
        end else begin
            if (step_cnt == 24'h7FFFFF) begin
                step_cnt <= 0;
                if (opcode == 3'b100) pc <= 0; 
                else pc <= pc + 1;
                manifold_reg <= reg_next;
            end else begin
                step_cnt <= step_cnt + 1;
            end
        end
    end

    // --- 3. The Nano Core (ALU) ---
    wire fault_detected;
    spu_nano_core u_core (
        .clk(`SPU_PIN_CLK),
        .reset(reset),
        .reg_curr({128'b0, reg_curr[127:0]}), // Map to 128-bit internal
        .opcode(opcode),
        .prime_phase(prime_phase),
        .sign_flip(sign_flip),
        .reg_out(reg_next[127:0]),
        .fault_detected(fault_detected)
    );
    assign reg_next[255:128] = 128'b0;

    // --- 4. OLED Visualizer ---
    // Clock divider for 61.44 kHz I2C pulse
    reg [7:0] i2c_clk_div;
    wire i2c_clk = i2c_clk_div[7];
    always @(posedge `SPU_PIN_CLK) i2c_clk_div <= i2c_clk_div + 1;

    spu_ssd1306_driver u_oled (
        .clk(i2c_clk),
        .reset(reset),
        .data_in(reg_curr[7:0]), // Visualize Axis A (Low 8 bits)
        .data_req(),
        .scl(oled_scl),
        .sda(oled_sda),
        .ready()
    );

    // --- 5. Telemetry (UART) ---
    wire uart_ready;
    wire uart_start = (step_cnt == 24'h0);

    surd_uart_tx #(
        .CLK_HZ(CLK_HZ),
        .BAUD(115200)
    ) u_telemetry (
        .clk(`SPU_PIN_CLK),
        .reset(reset),
        .data_in({31'b0, fault_detected, reg_curr[31:0]}), 
        .start(uart_start),
        .tx(`SPU_PIN_UART_TX),
        .ready(uart_ready)
    );

    // --- 6. Visual Reification ---
    assign `SPU_PIN_LED_R = reset | fault_detected;
    assign `SPU_PIN_LED_G = !reset & !fault_detected;
    assign `SPU_PIN_LED_B = !uart_ready;

endmodule
