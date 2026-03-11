// SPU-13 CORTEX (v1.9 Inception Edition)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Dynamic Soul Selection (PMOD vs Onboard Safe Mode).

`include "../../include/spu/spu13_pins.vh"
`include "../../core/soul_map.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // OLED Interface
    output wire oled_scl,
    output wire oled_sda,
    
    // External PMOD Soul (PMOD A)
    output wire eink_cs, // Shared with E-Ink pins for demo
    output wire eink_sck,
    input  wire eink_miso,
    
    // Internal Flash (Fixed)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
    output wire `SPU_PIN_UART_TX
);

    // --- 1. Boot Inception ---
    wire boot_ready;
    wire use_external;
    wire [23:0] soul_addr;
    wire reset = !`SPU_PIN_RST_N;

    spu_pmod_boot u_inception (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .ext_spi_cs_n(), // Placeholder for PMOD-specific CS
        .ext_spi_sck(),
        .ext_spi_miso(eink_miso),
        .int_flash_ready(1'b1),
        .soul_start_addr(soul_addr),
        .use_external(use_external),
        .boot_ready(boot_ready)
    );

    // --- 2. The Gemini Manifold ---
    wire global_fault;
    wire [127:0] combined_state;
    wire flash_we;
    wire [23:0] flash_write_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_gemini_manifold #(.CLK_HZ(12000000)) u_gemini (
        .clk(`SPU_PIN_CLK), .reset(!boot_ready),
        .global_fault(global_fault),
        .combined_state(combined_state),
        .flash_we(flash_we), .flash_addr(flash_write_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    // --- 3. The Flash Bridge ---
    // If use_external is high, we direct commands to the PMOD
    // For now, we assume the internal controller handles the multiplexing
    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we), 
        .addr(boot_ready ? (use_external ? 24'h0 : soul_addr) : soul_addr),
        .data_in(soul_page), .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 4. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = global_fault | !boot_ready;
    assign `SPU_PIN_LED_G = boot_ready && !use_external; // Green: Internal Safe Soul
    assign `SPU_PIN_LED_B = boot_ready && use_external;  // Blue: External PMOD Soul

endmodule
