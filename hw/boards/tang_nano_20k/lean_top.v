// Tang Nano 20k Gemini Manifold (v1.4 Sovereign Parity)
// Target: Gowin GW2AR-18C
// Objective: Dual-Core Mutual Witnessing with cognitive and communicative parity.

`include "../../include/spu/spu13_pins.vh"
`include "../../core/soul_map.vh"

module tang_nano_20k_top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    output wire `SPU_PIN_UART_TX,
    
    // Physical SPI Flash (Soul)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
    // Artery Bus
    output wire artery_out,
    input  wire artery_in,
    
    // OLED Interface
    output wire oled_scl,
    output wire oled_sda
);

    wire reset = !`SPU_PIN_RST_N;
    wire clk_resonant;
    
    // --- 1. Resonant Heart (27MHz Source) ---
    spu_resonant_heart #(.CLK_IN_HZ(27000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. The Gemini Manifold ---
    wire global_fault;
    wire [127:0] combined_state;
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_gemini_manifold #(.CLK_HZ(27000000)) u_gemini (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .global_fault(global_fault),
        .combined_state(combined_state),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    // --- 3. Predictive Coding ---
    wire is_dissonant;
    spu_active_inference u_inference (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .prior_state(combined_state),
        .prior_precision(16'h0100),
        .sensory_in(combined_state), 
        .sensory_valid(1'b1),
        .posterior_state(), .prediction_error(),
        .is_dissonant(is_dissonant)
    );

    // --- 4. Communication (Laminar PHY) ---
    spu_laminar_phy u_phy (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .heartbeat_in(clk_resonant),
        .target_axis(2'b00),
        .is_transmitting(1'b0),
        .artery_out(artery_out),
        .axis_match()
    );

    // --- 5. The Flash Sealer ---
    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we), .addr(flash_addr),
        .data_in(soul_page), .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 6. Voice of Coherency ---
    spu_whisper_sane #(.CLK_HZ(27000000), .BAUD(115200)) u_sane (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!global_fault && !is_dissonant), .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 7. Aura Mapping ---
    assign `SPU_PIN_LED_R = global_fault | is_dissonant;
    assign `SPU_PIN_LED_G = !global_fault & !is_dissonant;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
