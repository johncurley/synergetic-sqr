// SPU-13 CORTEX (v1.8 Gemini Edition)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Dual-Core Gemini Manifold with Mutual Witnessing.

`include "../../include/spu/spu13_pins.vh"
`include "../../core/soul_map.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    output wire oled_scl,
    output wire oled_sda,
    
    output wire audio_out,
    output wire `SPU_PIN_UART_TX,
    
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso
);

    // --- 1. Temporal Axis ---
    wire reset = !`SPU_PIN_RST_N;
    wire clk_resonant;
    
    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. The Gemini Manifold (Dual-Core) ---
    wire global_fault;
    wire [127:0] combined_state;
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_gemini_manifold #(.CLK_HZ(12000000)) u_gemini (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .global_fault(global_fault),
        .combined_state(combined_state),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    // --- 3. The Soul Sealer ---
    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we), .addr(flash_addr),
        .data_in(soul_page), .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 4. Voice & Vision ---
    spu_ssd1306_driver u_oled (
        .clk(clk_resonant), .reset(reset),
        .data_in(combined_state[7:0]), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    spu_pwm_audio u_voice (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(combined_state[31:0]), .audio_out(audio_out)
    );

    spu_whisper_sane #(.CLK_HZ(12000000)) u_sane (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!global_fault), .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 5. Aura Mapping ---
    assign `SPU_PIN_LED_R = global_fault;
    assign `SPU_PIN_LED_G = !global_fault;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
