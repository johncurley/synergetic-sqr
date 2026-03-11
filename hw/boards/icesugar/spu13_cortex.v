// SPU-13 CORTEX (v1.10 Autopoietic Edition)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Self-Replicating Manifold via Flash Mirroring.

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
    
    // External PMOD SPI (The Mirror Target)
    output wire eink_cs,
    output wire eink_sck,
    output wire eink_mosi,
    input  wire eink_miso,
    
    // Internal Flash (The Source)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX
);

    // --- 1. Temporal Axis ---
    wire reset = !`SPU_PIN_RST_N;
    wire clk_resonant;
    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. Instruction Decoding (MIRR) ---
    wire [7:0] rx_data;
    wire rx_ready;
    uart_rx_mini #(.CLK_HZ(12000000), .BAUD(115200)) u_ear (
        .clk(`SPU_PIN_CLK), .rx_pin(`SPU_PIN_UART_RX),
        .rx_data(rx_data), .rx_ready(rx_ready)
    );
    // Trigger mirror if ASCII 'M' received or MIRR opcode detected
    wire start_mirror = rx_ready && (rx_data == 8'h4D); 

    // --- 3. The Mirror Conductor ---
    wire mirror_active;
    wire int_read_en, ext_write_en;
    wire [23:0] int_addr, ext_addr;
    wire [255:0] mirror_data;
    wire int_ready, ext_ready;

    spu_manifold_mirror u_mirror (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .start_mirror(start_mirror),
        .int_read_en(int_read_en), .int_addr(int_addr),
        .int_data_in(int_data_stream), .int_ready(int_ready),
        .ext_write_en(ext_write_en), .ext_addr(ext_addr),
        .ext_data_out(mirror_data), .ext_ready(ext_ready),
        .mirror_active(mirror_active), .mirror_done()
    );

    // --- 4. Dual Flash Controllers ---
    // Controller A: Internal (Source)
    wire [255:0] int_data_stream;
    spu_flash_controller u_int_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(1'b0), .read_en(int_read_en),
        .addr(int_addr), .data_in(256'b0), .data_out(int_data_stream),
        .ready(int_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck), .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // Controller B: External (Destination)
    spu_flash_controller u_ext_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(ext_write_en), .read_en(1'b0),
        .addr(ext_addr), .data_in(mirror_data), .data_out(),
        .ready(ext_ready),
        .spi_cs_n(eink_cs), .spi_sck(eink_sck), .spi_mosi(eink_mosi), .spi_miso(eink_miso)
    );

    // --- 5. Aura Mapping ---
    assign `SPU_PIN_LED_R = mirror_active; // Red indicates "Cloning" in progress
    assign `SPU_PIN_LED_G = !mirror_active;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
